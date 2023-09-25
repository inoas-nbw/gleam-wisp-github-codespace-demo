import app/web
import gleam/http.{Get, Post}
import gleam/list
import gleam/result
import gleam/string_builder
import wisp.{Request, Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  // For GET requests, show the form,
  // for POST requests we use the data from the form
  case req.method {
    Get -> show_form()
    Post -> handle_form_submission(req)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}

pub fn show_form() -> Response {
  // In a larger application a template library or HTML form library might
  // be used here instead of a string literal.
  let html =
    "<form method='post' class='p-10'>
      <label class='block'>
        <div class='block'>Firstname</div>
        <input type='text' name='first_name' class='block py-1 px-2 border-solid border-2 border-sky-500 rounded'>
      </label>
      <label class='block mb-2'>
        <div class='block'>Lastname</div>
        <input type='text' name='last_name' class='block py-1 px-2 border-solid border-2 border-sky-500 rounded'>
      </label>
      <button type='submit' class='block mt-2 py-2 px-4 text-white bg-indigo-500 rounded'>Submit</button>
    </form>"
    |> wrap_html_layout
    |> string_builder.from_string
  wisp.ok()
  |> wisp.html_body(html)
}

pub fn handle_form_submission(req: Request) -> Response {
  // This middleware parses a `wisp.FormData` from the request body.
  // It returns an error response if the body is not valid form data, or
  // if the content-type is not `application/x-www-form-urlencoded` or
  // `multipart/form-data`, or if the body is too large.
  use formdata <- wisp.require_form(req)

  // The list and result module are used here to extract the values from the
  // form data.
  // Alternatively you could also pattern match on the list of values (they are
  // sorted into alphabetical order), or use a HTML form library.
  let result = {
    use first_name <- result.try(list.key_find(formdata.values, "first_name"))
    use last_name <- result.try(list.key_find(formdata.values, "last_name"))
    let greeting =
      "<div class='p-4'>Hi, " <> wisp.escape_html(first_name) <> " " <> wisp.escape_html(
        last_name,
      ) <> "!</div>"
    Ok(
      greeting
      |> wrap_html_layout,
    )
  }

  // An appropriate response is returned depending on whether the form data
  // could be successfully handled or not.
  case result {
    Ok(content) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(content))
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

fn wrap_html_layout(content: String) -> String {
  "<html>
    <head>
      <title>Gleam Wisp Demo</title>
      <script src='https://cdn.tailwindcss.com'></script>
    </head>
    <body>" <> content <> "</body>
  </html>"
}
