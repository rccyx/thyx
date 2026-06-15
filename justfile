alias fc := format-check
alias s := shell

f:
	bash -c 'find src -name "*.qml" -exec qmlformat -i {} +'

@format-check:
	bash -c '\
		find src -name "*.qml" -print0 \
		| xargs -0 qmlformat -i && \
		git diff --exit-code -- src \
	'

l:
	find src -name "*.qml" -exec qmllint {} +

@p:
	bash ./scripts/preview

@i:
	bash ./scripts/install

@u:
	bash ./scripts/uninstall

@shell:
	shellcheck -x ./scripts/install ./scripts/uninstall