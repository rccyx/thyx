alias fc:= format-check

f:
	bash -c 'find . -name "*.qml" -exec qmlformat -i {} +'

@format-check:
	bash -c '\
		find src ui -name "*.qml" -print0 \
		| xargs -0 qmlformat -i && \
		git diff --exit-code -- src ui \
	'
@p:
	bash ./preview