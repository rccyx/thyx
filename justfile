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
	bash ./package/preview

@i:
	bash ./package/install

@u:
	bash ./package/uninstall

@shell:
	shellcheck -x ./package/install ./package/uninstall
