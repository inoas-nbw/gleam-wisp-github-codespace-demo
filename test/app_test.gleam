import gleeunit
import gleeunit/should
import gleam/string
import wisp/testing
import app/router

pub fn main() {
  gleeunit.main()
}

pub fn view_form_test() {
  let response = router.handle_request(testing.get("/", []))

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html")])

  response
  |> testing.string_body
  |> string.contains("<html>")
  |> should.equal(True)
}

pub fn submit_wrong_content_type_test() {
  let response = router.handle_request(testing.post("/", [], ""))

  response.status
  |> should.equal(415)

  response.headers
  |> should.equal([
    #("accept", "application/x-www-form-urlencoded, multipart/form-data"),
  ])
}

pub fn submit_missing_parameters_test() {
  // The `METHOD_form` functions are used to create a request with a
  // `x-www-form-urlencoded` body, with the appropriate `content-type` header.
  let response =
    testing.post_form("/", [], [])
    |> router.handle_request()

  response.status
  |> should.equal(400)
}

pub fn submit_successful_test() {
  let response =
    testing.post_form(
      "/",
      [],
      [#("first_name", "Captain"), #("last_name", "Caveman")],
    )
    |> router.handle_request()

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html")])

  response
  |> testing.string_body
  |> should.equal(
    "<html>\n    <head>\n      <title>Gleam Wisp Demo</title>\n      <script src='https://cdn.tailwindcss.com'></script>\n    </head>\n    <body><div class='p-4'>Hi, Captain Caveman!</div></body>\n  </html>",
  )
}
