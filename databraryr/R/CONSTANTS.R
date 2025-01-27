#' Load Package-wide Constants into Local Environment
#' 
#' 

API_CONSTANTS <- "https://nyu.databrary.org/api/constants"

CREATE_SLOT <-
  "https://nyu.databrary.org/api/volume/%s/slot"
CREATE_UPLOAD_FLOW <-
  "https://nyu.databrary.org/api/volume/%s/upload"
CREATE_FILE_FROM_FLOW <-
  "https://nyu.databrary.org/api/volume/%s/asset"

DATABRARY_API <- "https://nyu.databrary.org/api"
DOWNLOAD_FILE <-
  "https://nyu.databrary.org/slot/%s/-/asset/%s/download"
DOWNLOAD_SESSION_ZIP <-
  "https://nyu.databrary.org/volume/%s/slot/%s/zip/%s"
DOWNLOAD_VOLUME_ZIP <- 
  "https://nyu.databrary.org/volume/%s/zip/false"

GET_SESSIONS_IN_VOL <-
  "https://nyu.databrary.org/api/volume/%s?records&containers=all"
GET_ACTIVITY_DATA <-
  "https://nyu.databrary.org/api/activity"
GET_PARTY_BY_ID <- "https://nyu.databrary.org/api/party/%s?parents&children&access"
GET_PARTY_NO_PARENTS_CHILDREN <- "https://nyu.databrary.org/api/party/%s"
GET_CONSTANTS <- "https://nyu.databrary.org/api/constants"
GET_PARTY_AVATAR <- "https://nyu.databrary.org/party/%s/avatar"

GET_SESSION_CSV <- "https://nyu.databrary.org/volume/%s/csv"
GET_SESSION_ACTIVITY <- "https://nyu.databrary.org/api/slot/%s/activity"
GET_SESSION_ZIP <- "https://nyu.databrary.org/volume/%s/slot/%s/zip/false"

GET_VOL_BY_ID <-
  "https://nyu.databrary.org/api/volume/%s?access&citation&links&funding&top&tags&excerpts&comments&records&containers=all&metrics&state"
GET_VOLUME_FUNDING <- "https://nyu.databrary.org/api/volume/%s?funding=all"
GET_VOLUME_MINIMUM <- "https://nyu.databrary.org/api/volume/%s"
GET_VOLUME_LINKS <- "https://nyu.databrary.org/api/volume/%s?links=all"
GET_VOLUME_TAGS <- "https://nyu.databrary.org/api/volume/%s?tags=all"
GET_VOLUME_ACTIVITY <- "https://nyu.databrary.org/api/volume/%s/activity"
GET_VOLUME_ZIP <- "https://nyu.databrary.org/volume/%s/zip/false"
GET_VOLUME_EXCERPTS <- "https://nyu.databrary.org/api/volume/%s?excerpts=all"

GET_ASSET_BY_ID <- "https://nyu.databrary.org/api/asset/%s"
GET_ASSET_BY_VOLUME_SESSION_ID <- "https://nyu.databrary.org/api/volume/%s/slot/%s/asset/%s"

LOGIN <- "https://nyu.databrary.org/api/user/login"
LOGOUT <- "https://nyu.databrary.org/api/user/logout"

QUERY_SLOT <-
  "https://nyu.databrary.org/api/slot/%s/-?records&assets&excerpts&tags&comments"
QUERY_VOLUME_FUNDER <- "https://nyu.databrary.org/api/funder?query=%s"
QUERY_KEYWORDS <- "https://nyu.databrary.org/api/search?q=%s"
QUERY_TAGS <- "https://nyu.databrary.org/api/tags/%s"

SESSION_CSV <- "https://nyu.databrary.org/volume/%s/csv"

UPLOAD_CHUNK <- "https://nyu.databrary.org/api/upload"
UPDATE_SLOT <- "https://nyu.databrary.org/api/slot/%s"

# Authentication parameters
USER_AGENT <-
  "databraryr (https://cran.r-project.org/package=databraryr)"
KEYRING_SERVICE <- 'org.databrary.databraryr'

# httr2 request parameters
RETRY_LIMIT <- 3
RETRY_WAIT_TIME <- 1  # seconds
RETRY_BACKOFF <- 2  # exponential backoff
REQUEST_TIMEOUT <- 5 # seconds
REQUEST_TIMEOUT_VERY_LONG <- 600
