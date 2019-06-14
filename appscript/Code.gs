// AppScript apparently can't handle global consts, therefore we declare 'constants' as vars...
var BASE_URL = "https://firestore.googleapis.com/v1/"
var PATH_DATABASE = "projects/dachzeltfestival/databases/(default)/"
var PATH_SCHEDULE = PATH_DATABASE + "documents/schedule/"
var SCHEDULE_URL = BASE_URL + PATH_SCHEDULE
var TRANSACTION_URL = BASE_URL + PATH_DATABASE + "documents/:beginTransaction"
var TRANSACTION_COMMIT_URL = BASE_URL + PATH_DATABASE + "documents:commit"

/**
* Writes the table rows into a Cloud Firestore collection
**/
function myOnEdit(e) {

    const sheet = e.range.getSheet()
    const range = sheet.getDataRange()
    const sheetValues = range.getValues()

    const token = ScriptApp.getOAuthToken()

    // We delete and re-write the whole collection. Hence we need a transaction.
    const transactionId = startTransaction(token)

    // Parse table rows to Firestore Update objects
    const updates = parseTableToUpdateObjects(sheetValues)

    // Create Delete objects for each document currently in the Firestore collection. Do the necessary read within the transaction.
    const deletes = createDeleteObjectsForCurrentCollection(token, transactionId)

    // Execute delete+write operations, commit transaction
    commit(token, deletes, updates, transactionId)
}

function parseTableToUpdateObjects(sheetValues) {
  const headers = {}
  sheetValues[0].forEach(function(value, index) {
      headers[index] = value
  })

  const items = []
  sheetValues.slice(1, sheetValues.length).forEach(function(row, rowIndex) {
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
    items[rowIndex] = {
      update: {
        name: PATH_SCHEDULE + rowIndex,
        fields: entries
      }
    }
  })
  return items
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

function createDeleteObjectsForCurrentCollection(token, transactionId) {
  const listResponse = UrlFetchApp.fetch(SCHEDULE_URL + '?transaction=' + encodeURIComponent(transactionId) + "&pageSize=1000", {
    muteHttpExceptions: true,
    method: 'get',
    headers: {
        'Authorization': 'Bearer ' + token,
      }
  })
  Logger.log(listResponse)
  const documents = JSON.parse(listResponse.getContentText()).documents
  const deletes = documents.map(function(document) {
    return {
      'delete': document.name
    }
  })
  return deletes
}

function commit(token, deletes, updates, transactionId) {
  const commitResponse = UrlFetchApp.fetch(TRANSACTION_COMMIT_URL, {
      muteHttpExceptions: true,
      method: 'post',
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json'
      },
      payload: JSON.stringify({
        transaction: transactionId,
        writes: deletes.concat(updates)
      })
    })
    Logger.log(commitResponse)
}
