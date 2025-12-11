"""Model Tests

Comprehensive testing suite for neural network models:
- Layerwise unit tests (layer-by-layer verification)
- End-to-end integration tests (complete model testing)
- Forward pass validation
- Backward pass and gradient checking
- Save/load functionality

Current Models:
- LeNet-5: Classic CNN for MNIST/EMNIST classification
  - test_lenet5_layers.mojo: Layerwise unit tests (12 layer operations)
  - test_lenet5_e2e.mojo: End-to-end integration tests
- VGG-16: Classic deep CNN for CIFAR-10
  - test_vgg16_layers.mojo: Layerwise unit tests (13 conv → 5 unique + FC + pooling)
  - test_vgg16_e2e.mojo: End-to-end tests with full model forward/backward
- DenseNet-121: Dense convolutional network for CIFAR-10
  - test_densenet121_layers.mojo: Layerwise tests (58 conv → 14 unique tests)
  - test_densenet121_e2e.mojo: End-to-end tests with CIFAR-10 dataset
- ResNet-18: Residual network with skip connections for CIFAR-10
  - test_resnet18_layers.mojo: Layerwise tests (residual blocks, skip connections, BatchNorm)
  - test_resnet18_e2e.mojo: End-to-end tests with full model forward/backward
"""
