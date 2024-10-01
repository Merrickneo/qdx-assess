import torch
from torchvision import models, transforms
from PIL import Image
import json

# Check if CUDA is available
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load a pre-trained ResNet model
model = models.resnet18(pretrained=True)
model = model.to(device)
model.eval()

# Load the ImageNet class labels
with open("imagenet_classes.txt") as f:
    class_names = [line.strip() for line in f.readlines()]

# Define a transformation for the input image
transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

def classify_image(image_path):
    # Load the image

    image = Image.open(image_path)
    
    # Apply the transformation
    image = transform(image).unsqueeze(0).to(device)  # Add batch dimension and move to GPU if available
    
    # Perform inference
    with torch.no_grad():
        output = model(image)
    
    # Get the predicted class
    _, predicted_class = torch.max(output, 1)
    
    # Map the predicted class to the class name
    prediction = class_names[predicted_class.item()]
    confidence = torch.nn.functional.softmax(output, dim=1)[0, predicted_class].item()

    # Create the result as a JSON object
    result = {
        "prediction": prediction,
        "confidence": confidence
    }

    # Return the result as a JSON string
    return json.dumps(result)

# # Example usage
# example_inputs = [
#     {"image_path": "/Users/merrick/Downloads/govtech-assessment/qdx/image_input/cup.jpg"},
#     {"image_path": "/Users/merrick/Downloads/govtech-assessment/qdx/image_input/apple.jpg"}
# ]

# for input_data in example_inputs:
#     input_json = json.dumps(input_data)
#     print(classify_image(input_json))
