package:
	swift build

example:
	cd Example && swift build

ci:
ifndef ACTION
	$(error ACTION is not defined)
endif
	make $(ACTION)
