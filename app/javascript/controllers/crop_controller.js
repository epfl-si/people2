import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";

export default class extends Controller {
  static targets = ["source", "output", "cropButton", "field", "file", "form"];
  connect() {
    const originalImageUrl = this.element.dataset.originalImageUrl;
    if (originalImageUrl) {
      this.sourceTarget.src = originalImageUrl;
      this.sourceTarget.addEventListener("load", () => {
        this.createCropper();
      });
    } else {
      console.error("Original image URL is missing.");
    }
  }

  createCropper() {
    this.cropper = new Cropper(this.sourceTarget, {
      autoCropArea: 1,
      aspectRatio: 250 / 360,
      viewMode: 3,  
      dragMode: "none",
      responsive: true,
      zoomOnWheel: false,
      background: false,
      cropBoxResizable: true,
      cropBoxMovable: true,
      ready: () => {
        this.formatImageToScreen();
      },
      crop: () => {
        this.updatePreview();
        this.updateFileInput();
      },
    });
  }

  formatImageToScreen() {
    const containerData = this.cropper.getContainerData();
    const imageData = this.cropper.getImageData();

    // Dimensions minimales ajustées pour l'affichage réduit
    const minWidth = 250;
    const minHeight = 360;

    const widthRatio = containerData.width / imageData.naturalWidth;
    const heightRatio = containerData.height / imageData.naturalHeight;
    const scaleRatio = Math.min(widthRatio, heightRatio, 1);

    const scaledWidth = imageData.naturalWidth * scaleRatio;
    const scaledHeight = imageData.naturalHeight * scaleRatio;

    this.cropper.setCanvasData({
      width: scaledWidth,
      height: scaledHeight,
    });

    this.cropper.setCropBoxData({
      width: Math.max(250, minWidth),
      height: Math.max(360, minHeight),
      left: (containerData.width - Math.max(250, minWidth)) / 2,
      top: (containerData.height - Math.max(360, minHeight)) / 2,
    });
  }

  updatePreview() {
    const canvas = this.cropper.getCroppedCanvas({
      width: 250,
      height: 360,
    });

    const croppedImageDataUrl = canvas.toDataURL();

    const output1 = this.outputTargets.find((output) => output.id === "output");
    if (output1) {
      output1.src = croppedImageDataUrl;
    }

    const output2 = this.outputTargets.find((output) => output.id === "rounded_output");
    if (output2) {
      output2.src = croppedImageDataUrl;
    }
  }

  updateFileInput() {
    const canvas = this.cropper.getCroppedCanvas({
      width: 250,
      height: 360,
    });

    canvas.toBlob((blob) => {
      let file = new File([blob], "cropped_image.jpg", { type: "image/jpeg" });
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      this.fileTarget.files = dataTransfer.files;    
    }, 'image/jpeg');
  }
}
