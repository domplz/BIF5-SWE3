enum QueryOperation {
  noOperation,
  not,
  and,
  or,
  beginGroup,
  endGroup,
  equals,
  like,
  // isIn bc in is a keyword
  isIn,
  greaterThan,
  lessThan,
}
