alias fc:= format-check
alias s:= shell

f:
	bash -c 'find . -name "*.qml" -exec qmlformat -i {} +'

@format-check:
	bash -c '\
		find src ui -name "*.qml" -print0 \
		| xargs -0 qmlformat -i && \
		git diff --exit-code -- src ui \
	'
l:
	find src ui -name "*.qml" -exec qmllint {} +

@p:
	bash ./preview

@shell:
	shellcheck -x install uninstall
