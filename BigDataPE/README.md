
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BigDataPE <a href="https://github.com/StrategicProjects/bigdatape"><img src="man/figures/logo.png" align="right" height="106" alt="BigDataPE website" /></a>

<!-- badges: start -->

![](https://img.shields.io/badge/devel%20version-0.0.9-blue.svg)
<!-- badges: end -->

> **Note:** To access the BigDataPE APIs, you must be connected to the
> “PE Integrado” network or use a VPN.

**BigDataPE** is an R package that provides a secure and intuitive way
to access datasets from the BigDataPE platform. The package allows users
to fetch data from the API using token-based authentication, manage
multiple tokens for different datasets, and retrieve data efficiently
using chunking.

## Installation

You can install the `BigDataPE` package directly from GitHub:

``` r
# Install the devtools package if you haven't already
install.packages("devtools")

# Install BigDataPE from GitHub
devtools::install_github("StrategicProjects/bigdatape")
```

After installation, load the package:

``` r
library(BigDataPE)
```

## Features

- Securely store and manage API tokens with the `keyring` package.
- Fetch data from the BigDataPE API using a simple interface.
- Retrieve large datasets iteratively using chunking.
- Easily manage multiple datasets and their associated tokens.

## Functions Overview

### 1. Store Token: `bdpe_store_token`

This function securely stores an authentication token for a specific
dataset.

``` r
bdpe_store_token(base_name, token)
```

**Parameters**:

- `base_name`: The name of the dataset.
- `token`: The authentication token for the dataset.

**Example**:

``` r
bdpe_store_token("education_dataset", "your-token-here")
```

------------------------------------------------------------------------

### 2. Retrieve Token: `bdpe_get_token`

This function retrieves the securely stored token for a specific
dataset.

``` r
bdpe_get_token(base_name)
```

**Parameters**:

- `base_name`: The name of the dataset.

**Example**:

``` r
token <- bdpe_get_token("education_dataset")
```

------------------------------------------------------------------------

### 3. Remove Token: `bdpe_remove_token`

This function removes the token associated with a specific dataset.

``` r
bdpe_remove_token(base_name)
```

**Parameters**:

- `base_name`: The name of the dataset.

**Example**:

``` r
bdpe_remove_token("education_dataset")
```

------------------------------------------------------------------------

### 4. List Tokens: `bdpe_list_tokens`

This function lists all datasets with stored tokens.

``` r
bdpe_list_tokens()
```

**Example**:

``` r
datasets <- bdpe_list_tokens()
print(datasets)
```

------------------------------------------------------------------------

### 5. Fetch Data: `bdpe_fetch_data`

This function retrieves data from the BigDataPE API using securely
stored tokens.

``` r
bdpe_fetch_data(
  base_name, 
  limit = 100, 
  offset = 0, 
  query = list(), 
  endpoint = "https://www.bigdata.pe.gov.br/api/buscar")
```

**Parameters**:

- `base_name`: The name of the dataset.
- `limit`: Number of records per page. Default is `Inf`
- `offset`: Starting record for the query. Default is 0.
- `query`: Additional query parameters.
- `endpoint`: The API endpoint URL.

**Example**:

``` r
data <- bdpe_fetch_data("education_dataset", limit = 50)
```

------------------------------------------------------------------------

### 6. Fetch Data in Chunks: `bdpe_fetch_chunks`

This function retrieves data from the API iteratively in chunks.

``` r
bdpe_fetch_chunks(
  base_name, 
  total_limit = Inf, 
  chunk_size = 100, 
  query = list(), 
  endpoint = "https://www.bigdata.pe.gov.br/api/buscar")
```

**Parameters**:

- `base_name`: The name of the dataset.
- `total_limit`: Maximum number of records to fetch. Default is `Inf`
  (fetch all available data).
- `chunk_size`: Number of records per chunk. Default is 50.000
- `query`: Additional query parameters.
- `endpoint`: The API endpoint URL.

**Example**:

``` r
# Fetch up to 500 records in chunks of 100
data <- bdpe_fetch_chunks(
          "education_dataset", 
          total_limit = 500, 
          chunk_size = 100)

# Fetch all available data in chunks of 200
all_data <- bdpe_fetch_chunks(
              "education_dataset", 
              chunk_size = 200)
```

------------------------------------------------------------------------

### 7. Construct URL with Query Parameters: `parse_queries`

This internal function constructs a URL with query parameters.

``` r
parse_queries(url, query_list)
```

**Parameters**:

- `url`: The base URL.
- `query_list`: A list of query parameters.

**Example**:

``` r
url <- parse_queries(
            "https://www.example.com", 
            list(param1 = "value1", param2 = "value2")
            )
print(url)
```

------------------------------------------------------------------------

## Example Workflow

Here’s a complete example workflow:

``` r
# Store a token for a dataset
bdpe_store_token("education_dataset", "your-token-here")

# Fetch 100 records starting from the first record
data <- bdpe_fetch_data("education_dataset", limit = 100, offset = 0)

# Fetch data in chunks
all_data <- bdpe_fetch_chunks(
  "education_dataset", 
  total_limit = 500, 
  chunk_size = 100)

# List all datasets with stored tokens
datasets <- bdpe_list_tokens()

# Remove a token
bdpe_remove_token("education_dataset")
```

------------------------------------------------------------------------

## Contributing

If you find any issues or have feature requests, feel free to create an
issue or a pull request on
[GitHub](https://github.com/StrategicProjects/bigdatape).

------------------------------------------------------------------------

## License

This package is licensed under the MIT License. See the `LICENSE` file
for more details.
