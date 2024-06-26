# utils for working with XML

#' str2lang, but for xml children.
#'
#' [xml2::xml_text()] is deceptively close to obviating this helper, but it collapses
#'   text across lines. R is _mostly_ whitespace-agnostic, so this only matters in some edge cases,
#'   in particular when there are comments within an expression (`<expr>` node). See #1919.
#'
#' @noRd
xml2lang <- function(x) {
  x_strip_comments <- xml_find_all(x, ".//*[not(self::COMMENT or self::expr)]")
  str2lang(paste(xml_text(x_strip_comments), collapse = " "))
}


safe_parse_to_xml <- function(parsed_content) {
  if (is.null(parsed_content)) {
    return(xml2::xml_missing())
  }
  tryCatch(
    xml2::read_xml(xmlparsedata::xml_parse_data(parsed_content)),
    # use xml_missing so that code doesn't always need to condition on XML existing
    error = function(e) xml2::xml_missing()
  )
}

is_node <- function(xml) inherits(xml, "xml_node")
is_nodeset <- function(xml) inherits(xml, "xml_nodeset")
is_nodeset_like <- function(xml) {
  is_nodeset(xml) ||
    (is.list(xml) && all(vapply(xml, is_node, logical(1L))))
}
