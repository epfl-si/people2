import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";

export default class extends Controller {
  static targets = ["source", "output", "cropButton", "field", "form"];

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
      autoCropArea: 0.7,
      aspectRatio: 250 / 360,
      viewMode: 1,  
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
      },
    });
  }

  formatImageToScreen() {
    const containerData = this.cropper.getContainerData();
    const imageData = this.cropper.getImageData();

    // Dimensions minimales ajustées pour l'affichage réduit
    const minWidth = 125; // Réduction de l'affichage
    const minHeight = 180;

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

  click(event) {
    event.preventDefault();

    const canvas = this.cropper.getCroppedCanvas({
      width: 250,
      height: 360,
    });

    canvas.toBlob((blob) => {
      if (blob) {
        const reader = new FileReader();
        reader.onloadend = () => {
          this.fieldTarget.value = reader.result;
          this.formTarget.requestSubmit();
        };
        reader.readAsDataURL(blob);
      } else {
        console.error("Failed to generate blob from cropped canvas.");
      }
    }, "image/png");
  }
}
