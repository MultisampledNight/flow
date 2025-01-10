#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash gh tomlq rsync
set -eux
source `dirname $0`/common

# cleanup potentially previous runs on the same release
git tag --delete $version || true
git push origin :$version || true

git commit --allow-empty --message "release: $version"
git tag $version
git push
git push --tags

gh auth status
if [[ ! -d packages ]]; then
	gh repo fork $index --clone
fi

target="`pwd`/packages/packages/preview/$name/$version"

pushd $repo
	mkdir -p $target
	rsync -r \
		--exclude-from $repo/.gitignore \
		--exclude '.git*' \
		--exclude util \
		--exclude doc \
		$repo/ $target/
popd

pushd $target
	git switch --create "$name-$version"

	git add .
	git commit --message "$name:$version"
	git push -u origin @

	git switch main
popd
