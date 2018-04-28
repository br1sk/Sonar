package:
	swift build -Xswiftc -warnings-as-errors

ci:
ifndef ACTION
	$(error ACTION is not defined)
endif
	make $(ACTION)
