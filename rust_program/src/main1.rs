use pyo3::prelude::*;
use serde::{Deserialize, Serialize};
use std::error::Error;

// Define a struct for the Python inference result
#[derive(Serialize, Deserialize)]
struct InferenceResult {
    prediction: String,
    confidence: f32,
}

#[derive(Serialize, Deserialize)]
struct ImageInput {
    image_path: String,
}

fn main() -> Result<(), Box<dyn Error>> {
    println!("Hello, world!");
    // Initialize Python interpreter
    Python::with_gil(|py| -> PyResult<()> {
        // Path to the image (adjust the path as needed)
        let image_path = String::from("image_input/apple.jpg");

        // Create the input data
        let image_input = ImageInput {
            image_path: image_path.clone(),
        };

        // Serialize the input to JSON and map errors to PyErr
        let input_json = serde_json::to_string(&image_input).map_err(|e| {
            PyErr::new::<pyo3::exceptions::PyValueError, _>(format!("Failed to serialize input: {}", e))
        })?;

        // Convert the JSON string to a Python-compatible object
        let py_input_json = input_json.to_object(py);

        // Import Python script (ensure 'image_classifier.py' is in the correct directory)
        let inference_module = py.import_bound("image_classifier")?;

        println!("Hello World");
        
        // Call the Python function 'classify_image' with the input JSON as an argument
        let result_json: String = inference_module
            .call1(("classify_image", py_input_json))?  // Wrap input in a tuple
            .extract()?;
        
        println!("Result: {}", result_json);

        // Deserialize the JSON result from Python into the Rust struct and map errors to PyErr
        let inference_result: InferenceResult = serde_json::from_str(&result_json).map_err(|e| {
            PyErr::new::<pyo3::exceptions::PyValueError, _>(format!("Failed to deserialize result: {}", e))
        })?;

        // Print out the result
        println!(
            "Prediction: {}, Confidence: {}",
            inference_result.prediction, inference_result.confidence
        );

        Ok(())
    })?;

    Ok(())
}
