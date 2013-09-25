--[[
    Utilities API contains various functions that have no place in other APIs but don't need an entire API to themselves.

    @version 1.0 BIT
    @author  TheOriginalBIT, BIT
--]]

--[[
    Loads the contents of the supplied file into a table. Note the file must contain a string of a serialized table

    @param  fileName  string  the file to open and read from
    @return           table   a table from the contents of the file
--]]
function unserializeFile(fileName)
  assert(fs.exists(fileName), "File does not exist", 2)
  assert(not fs.isDir(fileName), "Cannot open a directory", 2)
  local file = assert(fs.open(fileName, "r"), "Cannot open file for read", 2)
  return textutils.unserialize(file.readAll()), file.close() --# returns nil, won't pollute the returns
end

--[[
    Converts a supplied file into a table of the lines contained within the file

    @param  fileName  string  the file to open and read from
    @return           table   the table of the files lines
--]]
function convertFileToTable(fileName)
  assert(fs.exists(fileName), "File does not exist", 2)
  assert(not fs.isDir(fileName), "Cannot open a directory", 2)
  local file = assert(fs.open(fileName, "r"), "Cannot open file for read", 2)
  local nTable = {}
  for line in file.readLine do
    table.insert(nTable, line)
  end
  file.close()
  return nTable
end

--[[
    Saves a supplied table into a file as a serialized table

    @param  fileName  string  the file to open
    @param  tTable    table   the table to save to file
--]]
function saveTable(fileName, tTable)
  assert(not fs.isDir(fileName), "cannot open a directory", 2)
  local file = assert(fs.open(fileName, "w"), "could not open file for write", 2)
  file.writeLine(textutils.serialize(tTable))
  file.close()
end

--[[
    Saves each entry of a supplied table into a file as a new line. Note: Key/value pairs will not be saved

    @param  fileName  string  the file to open
    @param  tTable    table   the table to save to file
--]]
function convertTableToFile(fileName, tTable)
  assert(not fs.isDir(fileName), "cannot open a directory", 2)
  local file = assert(fs.open(fileName,"w"), "could not open file for write", 2)
  file.write(table.concat(tTable, "\n"))
  file.close()
end