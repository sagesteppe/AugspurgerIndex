readme:
	Rscript -e 'rmarkdown::render("README.Rmd", encoding="UTF8")'
	sed -E -i \
		-e 's/\\\(/\$$/g' \
		-e 's/\\\)/\$$/g' \
		-e 's/^(> )?\\\[$$/\1$$$$/' \
		-e 's/^(> )?\\\]$$/\1$$$$/' \
		README.md

