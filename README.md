# meshblocknz

R package capturing meshblock data for New Zealand

## Installation

meshblocknz is not currently available from CRAN, but you can install it from github with:

```R
# install.packages("devtools")
devtools::install_github("jmarshallnz/meshblocknz")
```

## Usage

```R
library(meshblocknz)
head(mb_2013)
head(mb_2006)

# there is also old data (for backward compatibility - this will be removed once everything
# that relies on this is removed)
head(mb_2006_ur)
```
