require 'lib/date'


date = (dateString) ->
  date = new Date(dateString)
  formattedDate = date.toString('M/d/yyyy')
  if formattedDate.indexOf('NaN') is -1
    formattedDate
  else
    ''

dateTime = (dateTimeString) ->
  date = new Date(dateTimeString)
  formattedDate = date.toString('M/d/yyyy h:mm tt')
  if formattedDate.indexOf('NaN') is -1
    formattedDate
  else
    ''

boolean = (value) ->
  if not value?
    ' - '
  else if value
    'Yes'
  else
    'No'


money = (number) ->
  "$#{formatNumber(number, 2)}"

number = (number) ->
  formatNumber(number, 0)

formatNumber = (number, places) ->
  s = if number < 0 then "-" else ""
  i = parseInt(number = Math.abs(+number || 0).toFixed(places)) + ""
  j = if (j = i.length) > 3 then j % 3 else 0

  return s + (if j then i.substr(0, j) + ',' else "") +
           i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + ',') +
           (if places then "." + Math.abs(number - i).toFixed(places).slice(2) else "")

module.exports =
  date:     date
  dateTime: dateTime
  boolean:  boolean
  money:    money
  number:   number
