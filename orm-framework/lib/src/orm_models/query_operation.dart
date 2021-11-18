enum QueryOperation {
  nop,
  not,
  and,
  or,
  grp,
  endgrp,
  equals,
  like,
  // bc in is a keyword
  isIn,
  gt,
  lt,
}
