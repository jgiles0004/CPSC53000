// first line of the file should be the column headers
// first column should be the row titles
// all other values are expected to be strings and will be parsed Date and floats
// files should be saved as "text"
// empty rows are ignored
// extra whitespace is ignored


class OccupancyTable {
  int rowCount;
  int columnCount;
  String[][] data;
  String[] rowNames;
  String[] columnNames;
 float[] columnMaxes, columnMins;


  OccupancyTable(String filename) {
    String[] rows = loadStrings(filename);

    String[] columns = split(rows[0], ',');
    columnNames = subset(columns, 0); 
    scrubQuotes(columnNames);
    columnCount = columnNames.length;

    rowNames = new String[rows.length-1];
    data = new String[rows.length-1][];

    // start reading at row 1, because the first row was only the column headers
    for (int i = 1; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      // split the row on the commas
      String[] pieces = split(rows[i], ',');
      scrubQuotes(pieces);

      // copy row title
      rowNames[rowCount] = pieces[0];
      // copy data into the table starting at pieces[1]
      data[rowCount] = subset(pieces, 1);

      // increment the number of valid rows found so far
      rowCount++;
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
    
    setColMaxAndMin();
  }
  
  float[] getColMaxes(){
    return columnMaxes;
  }
  
  float[] getColMins(){
    return columnMins;
  }
  
  void setColMaxAndMin(){
    columnMaxes = new float[columnCount];
    columnMins = new float[columnCount];
    //Sets maximum and minum to float min and max
    for(int i=0; i< columnCount; i++){
      columnMins[i]=MAX_FLOAT;
      columnMaxes[i]=MIN_FLOAT;
    }
    for(int row=0; row<rowCount; row++){
      for(int i=0; i<columnCount;i++){
        float cell = parseFloat(data[row][i]);
        //Finds max for each column
        if(columnMaxes[i]<cell){
          columnMaxes[i]=cell;
        }
        //Finds the minimum for each column
        if(columnMins[i]>cell){
          columnMins[i]=cell;
        }
      }
    }
  }


  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }


  int getRowCount() {
    return rowCount;
  }


  String getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }


  String[] getRowNames() {
    return rowNames;
  }


  // Find a row by its name, returns -1 if no row found. 
  // This will return the index of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i].equals(name)) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }


  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  int getColumnCount() {
    return columnCount;
  }


  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }


  String[] getColumnNames() {
    return columnNames;
  }


  String get(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages

    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels

    return data[rowIndex][col];
  }
  
  float getFloat(int rowIndex, int col) {
    String val = get(rowIndex, col);
    if (!Float.isNaN(parseFloat(val))){
      return parseFloat(val);
    } else {
      throw new RuntimeException("Not a valid Float");
    }
  }


  boolean isValid(int row, int col) {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return data[row][col]!=null;
  }


  //float getColumnMin(int col) {
  //  float m = Float.MAX_VALUE;
  //  for (int i = 0; i < rowCount; i++) {
  //    if (!Float.isNaN(data[i][col])) {
  //      if (data[i][col] < m) {
  //        m = data[i][col];
  //      }
  //    }
  //  }
  //  return m;
  //}


  //float getColumnMax(int col) {
  //  float m = -Float.MAX_VALUE;
  //  for (int i = 0; i < rowCount; i++) {
  //    if (isValid(i, col)) {
  //      if (data[i][col] > m) {
  //        m = data[i][col];
  //      }
  //    }
  //  }
  //  return m;
  //}


  //float getRowMin(int row) {
  //  float m = Float.MAX_VALUE;
  //  for (int i = 0; i < columnCount; i++) {
  //    if (isValid(row, i)) {
  //      if (data[row][i] < m) {
  //        m = data[row][i];
  //      }
  //    }
  //  }
  //  return m;
  //} 


  //float getRowMax(int row) {
  //  float m = -Float.MAX_VALUE;
  //  for (int i = 1; i < columnCount; i++) {
  //    if (!Float.isNaN(data[row][i])) {
  //      if (data[row][i] > m) {
  //        m = data[row][i];
  //      }
  //    }
  //  }
  //  return m;
  //}


  //  float getTableMin() {
  //    float m = Float.MAX_VALUE;
  //    for (int i = 0; i < rowCount; i++) {
  //      for (int j = 0; j < columnCount; j++) {
  //        if (isValid(i, j)) {
  //          if (data[i][j] < m) {
  //            m = data[i][j];
  //          }
  //        }
  //      }
  //    }
  //    return m;
  //  }


  //  float getTableMax() {
  //    float m = -Float.MAX_VALUE;
  //    for (int i = 0; i < rowCount; i++) {
  //      for (int j = 0; j < columnCount; j++) {
  //        if (isValid(i, j)) {
  //          if (data[i][j] > m) {
  //            m = data[i][j];
  //          }
  //        }
  //      }
  //    }
  //    return m;
  //  }
}