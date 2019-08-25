// AppScript apparently can't handle global consts, therefore we declare 'constants' as vars...
var BASE_URL = "https://firestore.googleapis.com/v1/"
var PATH_DATABASE = "projects/dachzeltfestival/databases/(default)/"
var PATH_SCHEDULE = PATH_DATABASE + "documents/schedule/"
var SCHEDULE_URL = BASE_URL + PATH_SCHEDULE
var PATH_VENUE = PATH_DATABASE + "documents/venue/"
var VENUE_URL = BASE_URL + PATH_VENUE
var TRANSACTION_URL = BASE_URL + PATH_DATABASE + "documents/:beginTransaction"
var TRANSACTION_COMMIT_URL = BASE_URL + PATH_DATABASE + "documents:commit"

/**
* Writes the table rows into a Cloud Firestore collection
**/
function publishToFirebase() {

    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet()
    const scheduleValues = spreadsheet.getSheetByName("Schedule").getDataRange().getValues()
    const venueValues = spreadsheet.getSheetByName("Venues").getDataRange().getValues()

    const token = ScriptApp.getOAuthToken()

    // We delete and re-write the whole collection. Hence we need a transaction.
    const transactionId = startTransaction(token)

    // Parse table rows to Firestore Update objects
    const scheduleUpdates = parseScheduleToUpdateObjects(scheduleValues)
    const venueUpdates = parseVenuesToUpdateObjects(venueValues)

    // Create Delete objects for each document currently in the Firestore collection. Do the necessary read within the transaction.
    const scheduleDeletes = createDeleteObjectsForCollection(SCHEDULE_URL, token, transactionId)
    const venueDeletes = createDeleteObjectsForCollection(VENUE_URL, token, transactionId)

    // Execute delete+write operations, commit transaction
    commit(token, scheduleDeletes
      .concat(scheduleUpdates)
      .concat(venueDeletes)
      .concat(venueUpdates), transactionId)
}

function parseScheduleToUpdateObjects(sheetValues) {
  return parseTableToUpdateObjects(sheetValues, 1, function(row, rowIndex, headers) {
    const entries = {}
    row.forEach(function(value, columnIndex) {
      const fieldName = headers[columnIndex]
      var valueDeclaration

      if (fieldName == 'start' || fieldName == 'finish') {
        valueDeclaration = { timestampValue: Utilities.formatDate(new Date(value), "GMT", "yyyy-MM-dd'T'HH:mm:ss'Z'") }
      } else {
        valueDeclaration = { stringValue: value }
      }

      entries[fieldName] = valueDeclaration
    })
    return {
      update: {
        name: PATH_SCHEDULE + rowIndex,
        fields: entries
      }
    }
  })
}

function parseVenuesToUpdateObjects(sheetValues) {
  return parseTableToUpdateObjects(sheetValues, 0, function(row, rowIndex, headers) {
    const entries = {}
    var venueId = null
    row.forEach(function(value, columnIndex) {
      const fieldName = headers[columnIndex]
      if (fieldName == 'venue_id') {
        venueId = value
      } else {
        entries[fieldName] = { stringValue: value }
      }
    })
    return {
      update: {
        name: PATH_VENUE + venueId,
        fields: entries
      }
    }
  })
}

function parseTableToUpdateObjects(sheetValues, headerRowIndex, rowMapper) {
  const headers = {}
  sheetValues[headerRowIndex].forEach(function(value, index) {
      headers[index] = value
  })
  return sheetValues.slice(headerRowIndex + 1, sheetValues.length).map(function(row, rowIndex) {
    return rowMapper(row, rowIndex, headers)
  })
}

function startTransaction(token) {
  const transactionResponse = UrlFetchApp.fetch(TRANSACTION_URL, {
      muteHttpExceptions: true,
      method: 'post',
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json'
      },
      payload: JSON.stringify({})
    })
    Logger.log(transactionResponse)
    const transactionId = JSON.parse(transactionResponse.getContentText()).transaction
    return transactionId
}

function createDeleteObjectsForCollection(collectionUrl, token, transactionId) {
  const listResponse = UrlFetchApp.fetch(collectionUrl + '?transaction=' + encodeURIComponent(transactionId) + "&pageSize=1000", {
    muteHttpExceptions: true,
    method: 'get',
    headers: {
        'Authorization': 'Bearer ' + token,
      }
  })
  Logger.log(listResponse)
  const documents = JSON.parse(listResponse.getContentText()).documents
  if (documents != null && documents.length > 0) {
    const deletes = documents.map(function(document) {
      return {
        'delete': document.name
      }
    })
    return deletes
  }
  return []
}

function commit(token, writes, transactionId) {
  const commitResponse = UrlFetchApp.fetch(TRANSACTION_COMMIT_URL, {
      muteHttpExceptions: true,
      method: 'post',
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json'
      },
      payload: JSON.stringify({
        transaction: transactionId,
        writes: writes
      })
    })
    Logger.log(commitResponse)
}
