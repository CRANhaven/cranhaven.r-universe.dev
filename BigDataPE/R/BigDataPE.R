#' Constructs a URL with query parameters
#'
#' This function appends a list of query parameters to a base URL.
#'
#' @param url The base URL to which query parameters will be added.
#' @param query_list A list of query parameters to be added to the URL.
#' @return The complete URL with the query parameters appended.
#' @examples
#' parse_queries("https://www.example.com", list(param1 = "value1", param2 = "value2"))
#' @export
parse_queries <- function(url, query_list) {
  if (length(query_list) == 0) {
    return(url) # Return the base URL if no queries are provided
  }

  # Filter out parameters with empty values
  query_list <- query_list[query_list != ""]

  # If no valid parameters remain, return the base URL
  if (length(query_list) == 0) {
    return(url)
  }

  # Encode parameters and construct the query string
  query_string <- paste(
    sapply(names(query_list), function(name) {
      paste0(
        utils::URLencode(name, reserved = TRUE), "=", utils::URLencode(as.character(query_list[[name]]), reserved = TRUE)
      )
    }),
    collapse = "&"
  )

  # Append the query string to the URL
  paste0(url, "?", query_string)
}


#' Store a token securely for a specific dataset
#'
#' This function securely stores an authentication token
#' for a specific dataset using the `keyring` package. If the
#' keyring is not accessible (e.g., in a virtual machine or unsupported environment),
#' it prints a message and does not attempt to store the token.
#'
#' @param base_name The name of the dataset.
#' @param token The authentication token for the dataset.
#'
#' @return No return value. If the keyring is available, the token is securely stored.
#'         Otherwise, a message is displayed.
#' @examples
#' bdpe_store_token("education_dataset", "your-token-here")
#' @export
bdpe_store_token <- function(base_name, token) {
  # Validate inputs
  if (!is.character(base_name) || !nzchar(base_name)) {
    stop("Dataset name must be a valid string.")
  }
  if (!is.character(token) || !nzchar(token)) {
    stop("Token must be a valid string.")
  }

  # Attempt to store the token in the keyring
  tryCatch(
    {
      keyring::key_set_with_value(service = "BigDataPE",
                                  username = base_name,
                                  password = token)
      message("Token successfully stored for dataset: ", base_name)
    },
    error = function(e) {
      # Graceful fallback if keyring is not accessible
      message("Keyring not accessible. Token could not be securely stored. Ensure the keyring is supported in this environment.")
    }
  )
}


#' Retrieve the token associated with a specific dataset
#'
#' This function retrieves the authentication token securely
#' stored for a specific dataset. If the token is not found,
#' it returns `NULL` and prints a message instead of throwing an error.
#'
#' @param base_name The name of the dataset.
#'
#' @return A string containing the authentication token, or `NULL` if the token is not found.
#' @examples
#' token <- bdpe_get_token("education_dataset")
#' @export
bdpe_get_token <- function(base_name) {
  if (!is.character(base_name) || !nzchar(base_name)) {
    stop("Dataset name must be a valid string.")
  }

  # Attempt to retrieve the token
  token <- tryCatch(
    keyring::key_get(service = "BigDataPE", username = base_name),
    error = function(e) NULL
  )

  # If token is NULL, print a message
  if (is.null(token)) {
    message("No token found for dataset: ", base_name)
    return(NULL)
  }

  return(token)
}

#' Remove the token associated with a specific dataset
#'
#' This function removes the securely stored authentication
#' token for a specific dataset. If the token is not found,
#' it prints a message and does not throw an error.
#'
#' @param base_name The name of the dataset.
#'
#' @return No return value. If the token is found, it is removed. If not, a message is displayed.
#' @examples
#' bdpe_remove_token("education_dataset")
#' @export
bdpe_remove_token <- function(base_name) {
  if (!is.character(base_name) || !nzchar(base_name)) {
    stop("Dataset name must be a valid string.")
  }

  # Attempt to remove the token
  tryCatch(
    {
      keyring::key_delete(service = "BigDataPE", username = base_name)
      message("Token successfully removed for dataset: ", base_name)
    },
    error = function(e) {
      message("No token found for dataset: ", base_name)
    }
  )
}

#' List all datasets with stored tokens
#'
#' This function returns a list of datasets that have stored tokens in the keyring.
#' If the keyring cannot be accessed (e.g., in a virtual machine or unsupported environment),
#' it returns an empty vector and prints a message.
#'
#' @return A character vector of dataset names with stored tokens. If the keyring cannot be accessed,
#' an empty vector is returned with a message.
#' @examples
#' bdpe_list_tokens()
#' @export
bdpe_list_tokens <- function() {
  tryCatch(
    {
      # Attempt to list keyring entries
      entries <- keyring::key_list(service = "BigDataPE")
      return(entries$username)
    },
    error = function(e) {
      # Graceful fallback if keyring cannot be accessed
      message("Keyring not accessible. Ensure the keyring is configured or supported in this environment.")
      return(character(0))
    }
  )
}



#' Fetch data from the BigDataPE API
#'
#' This function retrieves data from the BigDataPE API using securely stored tokens associated with datasets.
#' Users can specify pagination parameters (`limit` and `offset`) and additional query filters to customize the data retrieval.
#'
#' @param base_name A string specifying the name of the dataset associated with the token.
#' @param limit An integer specifying the maximum number of records to retrieve per request. Default is Inf (all records).
#'              If set to a non-positive value or `Inf`, no limit will be applied.
#' @param offset An integer specifying the starting record for the query. Default is 0.
#'               If set to a non-positive value or `Inf`, no offset will be applied.
#' @param query A named list of additional query parameters to filter the API results. Default is an empty list.
#' @param endpoint A string specifying the API endpoint URL. Default is "https://www.bigdata.pe.gov.br/api/buscar".
#' @param verbosity An integer specifying the verbosity level for the API requests.
#'                  Values are:
#'                  - `0`: No verbosity (default).
#'                  - `1`: Minimal verbosity, showing request status.
#'                  - `2`: Detailed verbosity, including request and response details.
#'
#' @return A tibble containing the data returned by the API.
#' @examples
#' \dontrun{
#' # Store a token for the dataset
#' bdpe_store_token("education_dataset", "your-token-here")
#'
#' # Fetch 50 records from the beginning
#' data <- bdpe_fetch_data("education_dataset", limit = 50)
#'
#' # Fetch records with additional query parameters
#' data <- bdpe_fetch_data("education_dataset", query = list(field = "value"))
#'
#' # Fetch all data without limits
#' data <- bdpe_fetch_data("education_dataset", limit = Inf)
#' }
#' @export
bdpe_fetch_data <- function(
    base_name,
    limit = Inf,
    offset = 0,
    query = list(),
    verbosity = 0,
    endpoint = "https://www.bigdata.pe.gov.br/api/buscar") {

  # Retrieve the token for the specified dataset
  token <- bdpe_get_token(base_name)

  # Input validation
  stopifnot(is.list(query))
  stopifnot(is.numeric(offset))
  stopifnot(is.numeric(limit) || is.infinite(limit))

  # Adjust limit and offset for the request
  if (is.infinite(limit) || limit <= 0) limit <- ""
  if (is.infinite(offset) || offset <= 0) offset <- ""

  # Build and send the API request
  req <- endpoint |>
    parse_queries(query_list = query) |>
    httr2::request() |>
    httr2::req_headers(
      Authorization = token,
      limit = limit,
      offset = offset
    )

  # Perform the request and parse the response
  res <- req |>
    httr2::req_perform(verbosity = verbosity) |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    tibble::as_tibble()

  return(res)
}


#' Fetch data from the BigDataPE API in chunks
#'
#' This function retrieves data from the BigDataPE API iteratively in chunks.
#' It uses `bdpe_fetch_data` as the base function and supports limits for the
#' total number of records to fetch and the size of each chunk.
#'
#' @param base_name A string specifying the name of the dataset associated with the token.
#' @param total_limit An integer specifying the maximum number of records to fetch. Default is Inf (all available data).
#' @param chunk_size An integer specifying the number of records to fetch per chunk. Default is 50000
#' @param query A named list of additional query parameters to filter the API results. Default is an empty list.
#' @param endpoint A string specifying the API endpoint URL. Default is "https://www.bigdata.pe.gov.br/api/buscar".
#' @param verbosity An integer specifying the verbosity level for the API requests.
#'                  Values are:
#'                  - `0`: No verbosity (default).
#'                  - `1`: Minimal verbosity, showing request status.
#'                  - `2`: Detailed verbosity, including request and response details.
#' @return A tibble containing all the data retrieved from the API.
#' @examples
#' \dontrun{
#' # Store a token for the dataset
#' bdpe_store_token("education_dataset", "your-token-here")
#'
#' # Fetch up to 500 records in chunks of 100
#' data <- bdpe_fetch_chunks("education_dataset", total_limit = 500, chunk_size = 100)
#'
#' # Fetch all available data in chunks of 200
#' data <- bdpe_fetch_chunks("education_dataset", chunk_size = 200)
#' }
#' @export
bdpe_fetch_chunks <- function(
    base_name,
    total_limit = Inf,
    chunk_size = 50000,
    query = list(),
    verbosity = 0,
    endpoint = "https://www.bigdata.pe.gov.br/api/buscar") {

  # Input validation
  stopifnot(is.numeric(total_limit) || is.infinite(total_limit))
  stopifnot(is.numeric(chunk_size) && chunk_size > 0)
  stopifnot(is.list(query))

  # Initialize variables
  offset <- 0
  total_fetched <- 0
  all_data <- list()

  # Fetch data in chunks
  repeat {
    # Calculate the limit for the current chunk
    current_limit <- min(chunk_size, total_limit - total_fetched)

    # Break if no more records are needed
    if (current_limit <= 0) break

    # Fetch the current chunk
    chunk <- bdpe_fetch_data(
      base_name = base_name,
      limit = current_limit,
      offset = offset,
      query = query,
      verbosity = verbosity,
      endpoint = endpoint
    )

    # Stop if the API returns no data
    if (nrow(chunk) == 0) break

    # Append the chunk to the results
    all_data <- append(all_data, list(chunk))
    total_fetched <- total_fetched + nrow(chunk)

    # Update the offset for the next chunk
    offset <- offset + nrow(chunk)

    # Break if the total limit is reached
    if (total_fetched >= total_limit) break
  }

  # Combine all chunks into a single tibble
  combined_data <- dplyr::bind_rows(all_data)
  return(combined_data)
}
