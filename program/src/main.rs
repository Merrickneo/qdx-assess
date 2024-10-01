use pyo3::prelude::*;
mod lib;

fn main() {
    // run the guess_the_number function
    // lib::guess_the_number();
    // Call the `image_classifier` function
    lib::image_classifier();
}
