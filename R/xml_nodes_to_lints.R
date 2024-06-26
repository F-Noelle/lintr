#' Convert an XML node or nodeset into a Lint
#'
#' Convenience function for converting nodes matched by XPath-based
#'   linter logic into a [Lint()] object to return.
#'
#' @details
#' The location XPaths, `column_number_xpath`, `range_start_xpath` and `range_end_xpath` are evaluated using
#' [xml2::xml_find_num()] and will usually be of the form `"number(./relative/xpath)"`.
#' Note that the location line number cannot be changed and lints spanning multiple lines will ignore `range_end_xpath`.
#' `column_number_xpath` and `range_start_xpath` are assumed to always refer to locations on the starting line of the
#' `xml` node.
#'
#' @inheritParams lint-s3
#' @param xml An `xml_node` object (to generate one `Lint`) or an
#'   `xml_nodeset` object (to generate several `Lint`s), e.g. as returned by
#'   [xml2::xml_find_all()] or [xml2::xml_find_first()] or a
#'   list of `xml_node` objects.
#' @param source_expression A source expression object, e.g. as
#'   returned typically by [lint()], or more generally
#'   by [get_source_expressions()].
#' @param lint_message The message to be included as the `message`
#'   to the `Lint` object. If `lint_message` is a character vector the same length as `xml`,
#'   the `i`-th lint will be given the `i`-th message.
#' @param column_number_xpath XPath expression to return the column number location of the lint.
#'   Defaults to the start of the range matched by `range_start_xpath`. See details for more information.
#' @param range_start_xpath XPath expression to return the range start location of the lint.
#'   Defaults to the start of the expression matched by `xml`. See details for more information.
#' @param range_end_xpath XPath expression to return the range end location of the lint.
#'   Defaults to the end of the expression matched by `xml`. See details for more information.
#'
#' @return For `xml_node`s, a `lint`. For `xml_nodeset`s, `lints` (a list of `lint`s).
#' @export
xml_nodes_to_lints <- function(xml, source_expression, lint_message,
                               type = c("style", "warning", "error"),
                               column_number_xpath = range_start_xpath,
                               range_start_xpath = "number(./@col1)",
                               range_end_xpath = "number(./@col2)") {
  if (length(xml) == 0L) {
    return(list())
  }
  if (is_nodeset_like(xml)) {
    lints <- .mapply(
      xml_nodes_to_lints,
      dots = list(xml = xml, lint_message = lint_message),
      MoreArgs = list(
        source_expression = source_expression,
        type = type,
        column_number_xpath = column_number_xpath,
        range_start_xpath = range_start_xpath,
        range_end_xpath = range_end_xpath
      )
    )
    class(lints) <- "lints"
    return(lints)
  } else if (!is_node(xml)) {
    stop(
      "Expected an xml_nodeset, a list of xml_nodes, or an xml_node, instead got an object of class(es): ",
      toString(class(xml)),
      call. = FALSE
    )
  }
  type <- match.arg(type, c("style", "warning", "error"))
  line1 <- xml_attr(xml, "line1")
  col1 <- xp_find_location(xml, range_start_xpath)
  if (is.na(col1)) {
    warning("Could not find range start for lint. Defaulting to start of line.", call. = FALSE)
    col1 <- 1L
  }

  lines <- source_expression[["lines"]]
  if (is.null(lines)) lines <- source_expression[["file_lines"]]

  if (xml_attr(xml, "line2") == line1) {
    col2 <- xp_find_location(xml, range_end_xpath)
    if (is.na(col2)) {
      warning("Could not find range end for lint. Defaulting to width 1.", call. = FALSE)
      col2 <- col1
    }
  } else {
    col2 <- nchar(lines[[line1]])
  }

  column_number <- xp_find_location(xml, column_number_xpath)
  if (is.na(column_number)) {
    warning("Could not find location for lint. Defaulting to start of range.", call. = FALSE)
    column_number <- col1
  }

  Lint(
    filename = source_expression$filename,
    line_number = as.integer(line1),
    column_number = column_number,
    type = type,
    message = lint_message,
    line = lines[[line1]],
    ranges = list(c(col1, col2))
  )
}
