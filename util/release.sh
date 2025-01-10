#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash gh tomlq rsync
set -eux

index="https://github.com/typst/packages"
repo=`git rev-parse --show-toplevel`
name=`basename $repo`
version=`tq --file $repo/typst.toml package.version`

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
		--exclude thumbnail/generate \
		$repo/ $target/
popd

pushd $target
	git switch --create "$name-$version"

	git add .
	git commit --message "$name:$version"
	git push -u origin @

	git switch main
popd
