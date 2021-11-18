enum QueryOperation {
  nop,
  not,
  and,
  or,
  beginGroup,
  endGroup,
  equals,
  like,
  // bc in is a keyword
  isIn,
  greaterThan,
  lessThan,
}
