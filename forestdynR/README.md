
# **forestdynR**

`forestdynR` is a package to calculate forest dynamics, including abundance, mortality and recruitment rates, basal area, and biomass. The function uses diameter at breast height (DBH) data to estimate forest dynamics over time.

### **1. INSTALLATION**

You can install the package directly from GitHub using the `devtools`. Run the following command in R:

```R
# Install devtools if you haven't already
install.packages('devtools')

# Install forestdynR from GitHub
devtools::install_github('https://github.com/higuchip/forestdynR.git')

#NOTE: To install this package from source on Windows, you must have the [Rtools](https://cran.rstudio.com/bin/windows/Rtools/) installed.

```
Or through CRAN, the official R repository. Run this command in R:

```R
install.packages('forestdynR')
```

### **2. USAGE**

#### 2.1 DESCRIPTION

The `forestdynR` package accepts data that must have the following arguments:

**Function Arguments:**
- `forest_df`: Data frame that must contain the following columns (not necessarily in this order):

  - `plot`: Plot identification.
  - `spp`: Species identification Species identification..
  - `DBH_1`: Diameter at breast height (DBH) in year 1 (numeric values).
  - `DBH_2`: Diameter at breast height (DBH) in year 2 (numeric values).
  
**Important:**
  - The columns DBH_1 and DBH_2 must contain numeric values;
  - You can add more columns, but columns `plot`, `spp`, `DBH_1` and `DBH_2`***must be present in the data frame***, because the function uses the column names to do the calculation.

- `inv_time`: Represents the time between inventories, in years (e.g.: 5);

- `coord`: Geographic coordinates in the format c(longitude, latitude), with values in decimal degrees (e.g.: c(-50.17,-27.71));

- `add_wd`: Optional data frame with wood density values (g/cm3). The expected format is a data frame with three columns:

  - `genus`: Genus of the species;
  - `species`: Species identification (scientific name);
  - `wd`: Wood density (g/cm3).
  
  **NOTE**: The `add_wd` is NULL by default. If the argument is not provided, wood density will be estimated automatically using the `getWoodDensity()` function from the `BIOMASS` package, based on the wood density database by Zanne et al., (2009).


Example file:
An example input file is available with the function, just call `data(forest_df_example)`, and you will have access to the database presented in `e.g. 1`.

`e.g.1: Example input file is available with the function`:

| plot |	n  |	spp                                         |	DBH_1 |	DBH_2 |
|------|-----|----------------------------------------------|-------|-------|
| 1	   | 1	 | Myrsine umbellata Mart.                      |	12,73	| 13,05 |
| 1	   | 3	 | Myrsine umbellata Mart.                      |	7,00	| 7,67  |
| 1	   | 4	 | Myrsine umbellata Mart.                      |	7,64	| 8,02  |
| 1	   | 5	 | Myrsine umbellata Mart.                      |	6,68	|       |
| 1	   | 6	 | Eugenia pluriflora DC.                       |	5,25	| 5,73  |
| 1	   | 7	 | Solanum sanctaecatharinae Dunal              |	6,73	| 7,77  |
| 1	   | 8	 | Podocarpus lambertii Klotzsch ex Endl.       |	17,44	| 17,51 |
| 1	   | 9	 | Matayba elaeagnoides Radlk.                  |	16,71	| 18,33 |
| 1	   | 10	 | Moquiniastrum polymorphum (Less.) G. Sancho  |	14,96	| 16,07 |
| 1	   | 11	 | Solanum sanctaecatharinae Dunal              |	19,86	| 22,09 |
| 1	   | 12	 | Araucaria angustifolia (Bertol.) Kuntze      |	4,97	| 5,51  |
| 1	   | 13	 | Casearia decandra Jacq.                      |	4,77	| 6,37  |
| 1	   | 14	 | Podocarpus lambertii Klotzsch ex Endl.       |	7,13	| 7,00  |
| 1	   | 15	 | Zanthoxylum kleinii (R.S.Cowan) P.G.Waterman |	5,38	| 5,44  |
| 1	   | 16	 | Jacaranda puberula Cham.                     |	9,45	| 9,87  |
| 1	   | 17	 | Calyptranthes concinna DC.                   |	5,41	| 6,05  |
| 1	   | 18	 | Duranta vestita Cham.                        |	5,32	| 5,57  |
| 1	   | 19	 | Jacaranda puberula Cham.                     |	9,23	| 9,84  |
| 1	   | 20	 | Myrcia laruotteana Cambess.                  |	15,96	| 15,89 |
| 1	   | B13 | Lithraea brasiliensis Marchand               |	19,80	| 23,78 |
| 1	   | 22	 | Lithraea brasiliensis Marchand               |	16,81	| 17,38 |
| 1	   | 23	 | Duranta vestita Cham.                        |	9,42	| 10,19 |
| 1	   | 24	 | Casearia decandra Jacq.                      |	8,35	| 8,51  |
| 1	   | 25	 | Jacaranda puberula Cham.                     |	10,38	| 11,94 |
| 1	   | 26	 | Ilex theezans Mart. ex Reissek               |	9,39	| 8,91  |
| 1	   | 27	 | Ocotea pulchella Mart.                       |	26,26	| 28,01 |
| 1	   | 28	 | Casearia decandra Jacq.                      |	8,28  |	      |
| 1	   | 29	 | Podocarpus lambertii Klotzsch ex Endl.       |	9,07	| 9,23  |
| 1	   | 30	 | Casearia decandra Jacq.                      |	6,68	| 7,96  |
[...]

- You can check that data set by running the command:

```R
data(forest_df_example)
```
				

#### 2.2 APPLYING THE FUNCTION

```R
#Example of usage os the forestdybR function

library(forestdynR) # Load package
data(forest_df_example) # Load your dataset

dyn_object <- forest_dyn(forest_df_example, 5, c(-50.17,-27.71)) # Run the function
```

#### 2.3 RETURN

The function returns a report containing the forest community dynamics, with abundance metrics, dynamic rates, basal area, and biomass by year. If you apply the example data `(data(forest_df_example))` to the function, the result will be the same as shown in the e.g.2.

`e.g.2: Function results`


```
forest_dyn(forest_df, 5, c(-50.17,-27.71))
NA's were turned into 0
The reference dataset contains 16467 wood density values
Your taxonomic table contains 25 taxa
```
```
dyn_object$dynamics$n_plot
```

|  |n0 |survivor |death |recruitment |n1| death_rate| recruitment_rate| net_change_rate| turn|
|--|---|---------|------|------------|--|-----------|-----------------|----------------|-----|
| 1| 46|       42|     4|           3|45|       1.80|             1.37|           -0.44| 1.59|
| 2| 35|       34|     1|           1|35|       0.58|             0.58|            0.00| 0.58|

```
dyn_object$dynamics$n_species
```

|                                                           |n0   |survivor |death |recruitment |n1   |death_rate |recruitment_rate |net_change_rate |turn |
|-----------------------------------------------------------|-----|---------|------|------------|-----|-----------|-----------------|----------------|-----|
|Allophylus edulis (A.St.-Hil., Cambess. & A.Juss.) Radlk.  |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Araucaria angustifolia (Bertol.) Kuntze                    |3    |3        |0     |1           |4    |0.00       |5.59             |5.92            |2.80 |
|Calyptranthes concinna DC.                                 |4    |4        |0     |0           |4    |0.00       |0.00             |0.00            |0.00 |
|Casearia decandra Jacq.                                    |7    |4        |3     |2           |6    |10.59      |7.79             | -3.04          |9.19 |
|Casearia obliqua Spreng.                                   |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Cupania vernalis Cambess.                                  |4    |4        |0     |1           |5    |0.00       |4.36             |4.56            |2.18 |
|Dasyphyllum spinescens (Less.) Cabrera                     |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Drimys brasiliensis Miers                                  |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Duranta vestita Cham.                                      |2    |2        |0     |0           |2    |0.00       |0.00             |0.00            |0.00 |
|Erythroxylum deciduum A.St.-Hil.                           |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Eugenia pluriflora DC.                                     |5    |5        |0     |0           |5    |0.00       |0.00             |0.00            |0.00 |
|Ilex theezans Mart. ex Reissek                             |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Jacaranda puberula Cham.                                   |13   |12       |1     |0           |12   |1.59       |0.00             | -1.59          |0.79 |
|Lamanonia ternata Vell.                                    |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Lithraea brasiliensis Marchand                             |5    |5        |0     |0           |5    |0.00       |0.00             |0.00            |0.00 |
|Matayba elaeagnoides Radlk.                                |3    |3        |0     |0           |3    |0.00       |0.00             |0.00            |0.00 |
|Maytenus dasyclada Mart.                                   |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Moquiniastrum polymorphum (Less.) G. Sancho                |4    |4        |0     |0           |4    |0.00       |0.00             |0.00            |0.00 |
|Myrcia laruotteana Cambess.                                |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Myrsine umbellata Mart.                                    |6    |5        |1     |0           |5    |3.58       |0.00             | -3.58          |1.79 |
|Ocotea pulchella Mart.                                     |3    |3        |0     |0           |3    |0.00       |0.00             |0.00            |0.00 |
|Podocarpus lambertii Klotzsch ex Endl.                     |7    |7        |0     |0           |7    |0.00       |0.00             |0.00            |0.00 |
|Scutia buxifolia Reissek                                   |1    |1        |0     |0           |1    |0.00       |0.00             |0.00            |0.00 |
|Solanum sanctaecatharinae Dunal                            |3    |3        |0     |0           |3    |0.00       |0.00             |0.00            |0.00 |
|Zanthoxylum kleinii (R.S.Cowan) P.G.Waterman               |2    |2        |0     |0           |2    |0.00       |0.00             |0.00            |0.00 |

```
dyn_object$dynamics$basal_area_plot
```

|   |BA_0   |AGB_0   |sur_gain |sur_loss  |BA_m  |BA_r  |BA_1   |AGB_1   |BA_loss_rate |BA_gain_rate |BA_net_change_rate |BA_turn |
|---|-------|--------|---------|----------|------|------|-------|--------|-------------|-------------|-------------------|--------|
|1  |0.7342 |4.3357  |0.0763   | -0.0200  |0     |0     |0.7802 |4.7101  |0.5517       |2.0379       |1.2232             |1.2948  |
|2  |1.1205 |7.7123  |0.1658   | -0.0038  |0     |0     |1.2815 |9.0881  |0.0674       |2.7336       |2.7223             |1.4005  |

```
dyn_object$dynamics$basal_area_species
```
|                                                           |BA_0   |AGB_0    |sur_gain |sur_loss  |BA_m |BA_r  |BA_1   |AGB_1   |BA_loss_rate |BA_gain_rate |BA_net_change_rate |BA_turn |
|-----------------------------------------------------------|-------|---------|---------|----------|-----|------|-------|--------|-------------|-------------|-------------------|--------|
|Allophylus edulis (A.St.-Hil., Cambess. & A.Juss.) Radlk.  |0.0058 |0.0195   |0.0002   |0.0000    |0    |0     |0.0060 |0.0205  |0.0000       |0.7313       |0.0000             |0.0000  |
|Araucaria angustifolia (Bertol.) Kuntze                    |0.1542 |0.8626   |0.0381   |0.0000    |0    |0     |0.1943 |1.1332  |0.0000       |4.2746       |5.9224             |2.7956  |
|Calyptranthes concinna DC.                                 |0.0191 |0.0785   |0.0016   | -0.0019  |0    |0     |0.0187 |0.0734  |2.1347       |1.7506       |0.0000             |0.0000  |
|Casearia decandra Jacq.                                    |0.0276 |0.0862   |0.0032   |0.0000    |0    |0     |0.0218 |0.0666  |0.0000       |3.0870       | -3.0360           |9.1890  |
|Casearia obliqua Spreng.                                   |0.0040 |0.0117   |0.0010   |0.0000    |0    |0     |0.0051 |0.0157  |0.0000       |4.4319       |0.0000             |0.0000  |
|Cupania vernalis Cambess.                                  |0.1103 |0.6360   |0.0218   | -0.0011  |0    |0     |0.1332 |0.8059  |0.1935       |3.5137       |4.5640             |2.1824  |   
|Dasyphyllum spinescens (Less.) Cabrera                     |0.3151 |2.9125   |0.0392   |0.0000    |0    |0     |0.3543 |3.3539  |0.0000       |2.3149       |0.0000             |0.0000  |
|Drimys brasiliensis Miers                                  |0.0050 |0.0104   |0.0000   | -0.0007  |0    |0     |0.0042 |0.0085  |3.1123       |0.0000       |0.0000             |0.0000  |
|Duranta vestita Cham.                                      |0.0092 |0.0265   |0.0014   |0.0000    |0    |0     |0.0106 |0.0319  |0.0000       |2.7850       |0.0000             |0.0000  |
|Erythroxylum deciduum A.St.-Hil.                           |0.0466 |0.3398   |0.0069   |0.0000    |0    |0     |0.0535 |0.4042  |0.0000       |2.7389       |0.0000             |0.0000  |
|Eugenia pluriflora DC.                                     |0.0276 |0.1105   |0.0020   |0.0000    |0    |0     |0.0296 |0.1212  |0.0000       |1.3638       |0.0000             |0.0000  |
|Ilex theezans Mart. ex Reissek                             |0.0069 |0.0215   |0.0000   | -0.0007  |0    |0     |0.0062 |0.0188  |2.0658       |0.0000       |0.0000             |0.0000  |
|Jacaranda puberula Cham.                                   |0.1012 |0.3522   |0.0189   |0.0000    |0    |0     |0.1170 |0.4301  |0.0000       |3.4610       | -1.5881           |0.7941  |
|Lamanonia ternata Vell.                                    |0.0021 |0.0052   |0.0000   |0.0000    |0    |0     |0.0021 |0.0051  |0.3028       |0.0000       |0.0000             |0.0000  |
|Lithraea brasiliensis Marchand                             |0.1775 |1.5421   |0.0274   | -0.0003  |0    |0     |0.2047 |1.8390  |0.0295       |2.8368       |0.0000             |0.0000  |
|Matayba elaeagnoides Radlk.                                |0.0733 |0.4762   |0.0047   | -0.0066  |0    |0     |0.0713 |0.4532  |1.8669       |1.3405       |0.0000             |0.0000  |
|Maytenus dasyclada Mart.                                   |0.0100 |0.0427   |0.0000   | -0.0054  |0    |0     |0.0046 |0.0156  |14.3771      |0.0000       |0.0000             |0.0000  |
|Moquiniastrum polymorphum (Less.) G. Sancho                |0.2310 |1.5133   |0.0140   | -0.0068  |0    |0     |0.2383 |1.5687  |0.5951       |1.2070       |0.0000             |0.0000  |
|Myrcia laruotteana Cambess.                                |0.0200 |0.1179   |0.0000   | -0.0002  |0    |0     |0.0198 |0.1165  |0.1871       |0.0000       |0.0000             |0.0000  |
|Myrsine umbellata Mart.                                    |0.0660 |0.3390   |0.0065   |0.0000    |0    |0     |0.0691 |0.3695  |0.0000       |1.9650       | -3.5807           |1.7904  |
|Ocotea pulchella Mart.                                     |0.2639 |1.8855   |0.0333   |0.0000    |0    |0     |0.2972 |2.1866  |0.0000       |2.3462       |0.0000             |0.0000  |
|Podocarpus lambertii Klotzsch ex Endl.                     |0.1295 |0.4894   |0.0115   | -0.0001  |0    |0     |0.1409 |0.5455  |0.0218       |1.6906       |0.0000             |0.0000  |
|Scutia buxifolia Reissek                                   |0.0077 |0.0385   |0.0010   |0.0000    |0    |0     |0.0087 |0.0452  |0.0000       |2.4622       |0.0000             |0.0000  |
|Solanum sanctaecatharinae Dunal                            |0.0368 |0.1200   |0.0093   |0.0000    |0    |0     |0.0462 |0.1584  |0.0000       |4.4114       |0.0000             |0.0000  |
|Zanthoxylum kleinii (R.S.Cowan) P.G.Waterman               |0.0044 |0.0103   |0.0001   |0.0000    |0    |0     |0.0045 |0.0108  |0.0000       |0.5954       |0.0000             |0.0000  |   



`dyn_object$report_df`

|       |Section        |Metric                |Value       |Unit    | 
|-------|---------------|----------------------|------------|--------|
|1      |Richness       |Richness year 1       |25.0000000  |species |
|2      |Richness       |Richness year 2       |25.0000000  |species |
|3      |Abundance      |Abundance year 1      |81.0000000  |ind     |
|4      |Abundance      |Abundance year 2      |80.0000000  |ind     |
|5      |Dynamics Rate  |Mortality Rate        |1.2662313   |% year  |
|6      |Dynamics Rate  |Recruitment Rate      |1.0206218   |% year  |
|7      |Dynamics Rate  |Net Change Rate in n  | -0.2481420 |% year  |
|8      |Dynamics Rate  |Turnover Rate in n    |1.1434265   |% year  |
|9      |Basal Area     |Basal Area year 1     |1.8547000   |m2      |
|10     |Basal Area     |Basal Area year 2     |2.0617000   |m2      |
|11     |Basal Area     |Basal Area Loss Rate  |0.2579729   |% year  |
|12     |Basal Area     |Basal Area Gain Rate  |2.4673349   |% year  |
|13     |Basal Area     |Net Change Rate in BA |2.1387080   |% year  |
|14     |Basal Area     |Turnover Rate in BA   |1.3626539   |% year  |
|15     |Biomass        |Biomass year 1        |12.0480000  |tons    |
|16     |Biomass        |Biomass year 2        |13.7982000  |tons    |


### **3. REFERENCES**

- KORNING, J.; BALSLEV, H. **Growth and mortality of trees in Amazonian tropical rain forest in Ecuador**. Journal of Vegetation Science, v.5, n.1, p.77-86, 1994.
- OLIVEIRA FILHO, A. T. et a. **Dinâmica da comunidade e populações arbóreas da borda e interior de um remanescente florestal na Serra da Mantiqueira, Minas Gerais, em um intervalo de cinco anos (1999-2004)**. Revista Brasileira de Botânica, v.30, n.1, p.149-161, 2007.
- SALAMI, B. et al. **Influência de variáveis ambientais na dinâmica do componente arbóreo em um fragmento de Floresta Ombrófila Mista em Lages, SC**. Scientia Forestalis, v.42, n.102, p.197-207, 2014.
- SHEIL, D.; DAVID, BURSLEM, D. F. R. P.; ALDER, D. **The interpretation and misinterpretation of mortality rate measures**. Journal of Ecology, v.83, n.2, p.331-333, 1995.
- SHEIL, D.; JENNINGS, S.; SAVILL, P. **Long-term permanent plot observations of vegetation dynamics in Budongo, a Ugandan rain forest**. Journal of Tropical Ecology, v.16, n.6, p.865-882, 2000.
- Zanne, A. E., et al. **Global wood density database**. Dryad, 2009.
- Chave et al. (2014) **Improved allometric models to estimate the above ground biomass of tropical trees**. Global Change Biology, 20 (10), 3177-3190
- REJOU-MECHAIN, M.; TANGUY, A.; PIPONIOT, C.; CHAVE, J.; HERAULT, B. BIOMASS: **Estimating Above ground Biomass and Its Uncertainty in Tropical Forests**. R package version 1.2. <https://CRAN.R-project.org/package=BIOMASS>


### **4. CONTRIBUTION**

Contributions are welcome! Feel free to open issues or pull requests.

### **5. LICENSE**

This package is licensed under the MIT License.

### **6. CONTACT**

If you have any questions, feel free to reach out:

- **Author:** Pedro Higuchi
- **Email:** higuchip@gmail.com

- **Co-author:** Ana Carolina da Silva
- **Email:** carol_sil4@yahoo.com.br

- **Co-author:** Adam Slabadack
- **Email:** arslabadack@gmail.com
