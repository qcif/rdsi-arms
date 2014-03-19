# Makefile

FILE=arms-test-plan.md

help:
	@echo "Targets:"
	@echo "  update         - update numbers and date in ${FILE}"
	@echo "  remove-numbers - remove numbers from ${FILE}"
	@echo "  clear          - deletes any temporary files"

update:
	./renumber-md-test-plan.pl --no-headings -o tmp.md ${FILE}
	mv tmp.md ${FILE}

remove-numbers:
	./renumber-md-test-plan.pl --clear -o tmp.md ${FILE}
	mv tmp.md ${FILE}

clean:
	rm -f tmp.md

#EOF
