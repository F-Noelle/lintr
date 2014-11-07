infix_tokens <- c(

  "'+'",
  "'-'",
  "GT",
  "GE",
  "LT",
  "LE",
  "EQ",
  "NE",
  "AND",
  "OR",
  "AND2",
  "OR2",
  "LEFT_ASSIGN",
  "RIGHT_ASSIGN",
  "EQ_ASSIGN",
  "SPECIAL",
  "'/'",
  "'^'",
  "'*'",

  NULL
  )

#' @describeIn linters check that all infix operators have spaces around them.
#' @export
infix_spaces_linter <- function(source_file) {
  lapply(ids_with_token(source_file, infix_tokens, fun=`%in%`),
    function(id) {
      parsed <- with_id(source_file, id)

      line <- source_file$lines[parsed$line1]
      around_operator <- substr(line, parsed$col1 - 1L, parsed$col2 + 1L)

      non_space_before <- re_matches(around_operator, rex(start, non_space))
      non_space_after <- re_matches(around_operator, rex(non_space, end))

      if (non_space_before || non_space_after) {

        # we only should check spacing if the operator is infix,
        # which only happens if there are two siblings
        is_infix <-
          length(siblings(source_file$parsed_content, parsed$id, 1)) %==% 2L

        if (is_infix) {
          if (non_space_before) {
            start <- parsed$col1 - 1L
          }
          if (non_space_after) {
            end <- parsed$col2 - 1L
          }

          Lint(
            filename = source_file$filename,
            line_number = parsed$line1,
            column_number = parsed$col1,
            type = "style",
            message = "Put spaces around all infix operators.",
            line = line,
            ranges = list(c(start, end))
            )

        }
      }

    })
}