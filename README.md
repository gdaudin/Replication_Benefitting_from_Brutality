---
contributors:
  - Guillaume Daudin
  - Gerhard de Kok
  - Klas Rönnebäck
---

# README


## Overview

This is a replication package for « Benefiting from Brutality? Profits of North Western Europe’s Slave Trade at the Eve of the Industrial Revolution ». The provide code constructs the analysis file from the two provided data sources (our own work and TSTD) using Stata. A main file runs all of the code to generate the data for the 15 figures and 3 tables in the paper. The replicator should expect the code to run in less than 10 minutes.

## Data Availability and Provenance Statements

### Statement about Rights

I certify that the authors of the manuscript have legitimate access to and permission to use the data used in this manuscript.

### Summary of Availability
All data **are** publicly available.
### Details on each Data Source

| Data.Name  | Data.Files | Location | Provided | Citation |
| -- | -- | -- | -- | -- | 
| Voyage Accounts of European Slave Trade Ventures 1600 1830 | transactions_hypothetical.csv; transactions.csv; ventures.csv | data/ | TRUE | Daudin et al. (2026) |
| Trans-Atlantic Slave Trade Database | tstddb-exp-2020.sav | external data/ | TRUE | The Trans-Atlantic Slave Trade Database. (2019).  |



### Voyage Accounts of European Slave Trade Ventures 1600 1830

The venture and transaction data have been collected by the authors. They are the 1.1 version of the Zenodo repository and are available under a Creative Commons Attribution 4.0 International license. https://doi.org/10.5281/zenodo.18789300.
A data dictionary is provided (data/Handbook slave trade profits databases.pdf). References are provided (data/Data Bibliographical References.pdf).

### Trans-Atlantic Slave Trade Database
The Trans-Atlantic Slave Trade data have been accessed in 2020. They have been collected by the Slave Voyages team. They are available  under a Creative Commons Attribution-Noncommercial 3.0 United States License. (https://legacy.slavevoyages.org/about/about#legal/9/en/). A copy of the data is provide as part of this archive. They have been accessed in 2020.
A data dictionary is provided (TSTD Codebook_2022.pdf)

## Computational requirements


### Software Requirements



- Stata (code was last run with version 19 on MacOS 26.3)
  - `estout` (version 3.30  25mar2022  Ben Jann)
  - `outreg2` (version 2.3.2  17aug2014 by roywada@hotmail.com -- based on outreg 3.0.6/4.0.0 by john_gallup@alum.swarthmore.edu)
  - `xfill` (v1.0.0 08/07/2002 ARB)
  - the program "`config_stata.do`" will install all dependencies locally, and should be run once.

IrrGD.do is a derivation of irr.do by Maximo Sangiacomo, version 2.0, Feb 2013. https://ideas.repec.org/c/boc/bocode/s457597.html

### Memory and Runtime Requirements

#### Summary

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine: less than 10 minutes

#### Details

The code was last run on a **Apple M4-Pro laptop with MacOS version 26.3**. 

## Description of programs

### Import data, select sample and create dataset
* `Import own data.do` Imports our venture and transaction data
*	`Enrich voyages and save ventures.do` Enriches the voyages and save an venture datafile
* `Enrich ventures db.do` Enrich the venture datafile
* `Compare and select sample.do` Looks at the available data, compare it with TSDT, reduces the sample. Produces tables 3-5
* `Database for profit and IRR computation.do` Merges the transaction and venture datasets. 

### Compute profit, describe and graph it
* `Profit computation.do`  Computes venture-specific profits
* `Descriptive statistics of profit.do` Produces descriptive statistics for profit. Produces table 2 
* `Profit graphs.do` Produces figures 2-4

### Analyze of profit

* `Profit analysis - survey method.do` Applies sample methods to analyse profits. Produces table 6 and Appendix table 1
* `Profit analysis - synchronisation.do` Checks for the synchronisation of profits. Produces Figure 6 and Appendix table 2

### Compute IRR

* `IRR computation.do` Computes Internal Rates of Return. Produces figure 5, table 7 and computations below table 7
* `irrGD.do` Is necessary for `IRR computation.do` to work.

-------
`Database for profit and IRR computation.do`, `Profit computation.do`, `Profit graphs.do`, `Profit analysis - synchronisation.do`, `IRR computation.do` can be run for different hypothesis (see Appendix A). They all create programs that have as arguments the value of the hypothesis:
* The baseline is  `0.5 1 1 0 1 0 1 0`, eg. `profit_graphs 0.5 1 1 0 1 0 1 0`
Only British/Dutch/French: British/Dutch/French (does not always work)
* Without Observations with outstanding claims: `. 1 1 0 1 0 1 0`
* Claims outstanding assumed to not have been paid at all: `0 1 1 0 1 0 1 0`
* Claims outstanding assumed to have been paid in full: 1 1 1 0 1 0 1 0
* Higher cost of hull relative to other outlays (25% instead of 17% in baseline): `0.5 1.5 1 0 1 0 1 0`
* Lower rate of depreciation (10% instead of baseline 25%): `0.5 1 0.83 0 1.2 0 1 0`
* Cost of insurance not added to any voyages: `0.5 1 1 0 1 0 0 0`
* Cost of insurance added to outlays, even in cases where accounts seem to suggest total outlays: `0.5 1 1 0 1 0 1 1`
* Value of hull (outgoing/incoming) added to outlays/returns, even in cases where accounts seem to suggest total outlays/returns: `0.5 1 1 1 1 1 1 0`
* Both value of hull and cost of insurance added, in cases where accounts seem to suggest total outlays/returns: `0.5 1 1 1 1 1 1 1`

-----------

- The file `do files/00_launcher` will run all the data import, reformat and analysis included in the paper.
- The program `config_stata.do` will install with the necessary dependencies.

### License for Code

The code is licensed under a MIT license. See [LICENSE](LICENSE) for details.

## Instructions to Replicators

- Run `programs/config_stata.do` once on a new system to install the necessary dependencies.
- Edit `do files/00_launcher.do`, line 2 to adjust the default path
- Run `do files/00_launcher.do` to run all steps in sequence.

## List of tables and programs

The provided code reproduces all numbers provided in text in the paper

| Figure/Table #    | Program                  | Line Number | Output file                      | Notes |
|-------------------|--------------------------|-------------|----------------------------------|-----------|
| Figure 1          | ????    |             | summarystats.csv                 |
| Figure 2          | `Profit graph.do`    |  88           | scatter_year_profit_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.png                 |
| Figure 3          | `Profit graph.do`    |  57           | hist_by_nationality_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.png                 |
| Figure 4          | `Profit graph.do`    |  29           | hist_venture_by_year_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.png                 |
| Figure 5          | `IRR computation.do`    |  236           | scatter_irr_profit_OR0_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.png                 |
| Figure 6          | `Profit analysis - synchronisation.do`    |  65           | profit_dispersio_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.png                 |
| Table 2           | `Descriptive statistics of profit.do`| 64          | Profits_bynatio_baseline.txt                       | (The stars in the column "Total" should be disregarded. They are just a consequence of the way I have programmed, but I do not seem to be able
to find an easy better way) |
| Table 3           | `Compare and select sample.do` | 55         | Compare_Sample_Nationality.txt                       |
| Table 4           | `Compare and select sample.do` | 163         | Compare_Sample_Fate.txt                       |
| Table 5         | `Compare and select sample.do`         |     419        |        Compare TSTD__support__sample_withTTest.txt                          |
| Table 6         | `Profit analysis - survey method.do`      |     339        | Top of Profit analysis survey robustess rake.txt                      |
| Table 7          | `IRR computation.do`      |    225         | IRR_profit.txt            |
| Appendix table 1         | `Profit analysis - survey method.do`      |    339         | Profit analysis survey robustess rake.txt            |
| Appendix table 2         | `Profit analysis - synchronisation.do`      |    87         | Profit analysis survey synchronisation.txt |
| Computations below Table 7 (« The key takeway... »)          | `IRR computation.do`      |    260-263         | No file           |

## References

Guillaume Daudin, de Kok, G., Rönnbäck, K., & Giraldes Rodrigues, M. (2026). gdaudin/Voyage-Accounts-of-European-Slave-Trade-Ventures-1600-1830: Replication data for Benefitting Brutality (1.1) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.18789300

The Trans-Atlantic Slave Trade Database. (2019). SlaveVoyages. https://www.slavevoyages.org (accessed 2020).

---

## Acknowledgements

The template for this Readme comes from [Social Science Data Editors](https://zenodo.org/records/7293838).
