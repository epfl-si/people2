import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";

export default class extends Controller {
  static targets = ["source", "outputDefault", "outputRounded", "file"];

  connect() {
    const originalImageUrl = this.element.dataset.originalImageUrl;
    if (originalImageUrl) {
      this.outputDefaultTarget.classList.add("image-preview-hidden");
      this.loadAndResizeImage(originalImageUrl);
    } else {
      console.error("Original image URL is missing.");
    }
  }

  loadAndResizeImage(imageUrl) {
    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = imageUrl;

    img.onload = () => {
      const resizedDataUrl = this.resizeImage(img, 1000);
      this.sourceTarget.src = resizedDataUrl;

      setTimeout(() => this.createCropper(), 300);
    };
  }

  resizeImage(img, maxWidth) {
    const ratio = img.width / img.height;
    const newWidth = Math.min(img.width, maxWidth);
    const newHeight = newWidth / ratio;

    const canvas = document.createElement("canvas");
    canvas.width = newWidth;
    canvas.height = newHeight;
    const ctx = canvas.getContext("2d");

    ctx.drawImage(img, 0, 0, newWidth, newHeight);
    return canvas.toDataURL("image/jpeg", 0.8);
  }

  createCropper() {
    if (this.cropper) {
      this.cropper.destroy();
    }

    requestIdleCallback(() => {
      this.cropper = new Cropper(this.sourceTarget, {
        autoCropArea: 0.7,
        aspectRatio: 1000 / 1440,
        viewMode: 1,
        dragMode: "none",
        responsive: true,
        zoomOnWheel: false,
        background: false,
        cropBoxResizable: true,
        cropBoxMovable: true,
        modal: true,
        ready: () => {
          this.formatImageToScreen();
        },
        crop: () => {
          this.updatePreview();
          this.updateFileInput();
        },
      });
    });
  }

  applyCropperUpdates(scaledWidth, scaledHeight, cropWidth, cropHeight, cropLeft, cropTop) {
    this.cropper.setCanvasData({
      left: (this.cropper.getContainerData().width - scaledWidth) / 2,
      top: (this.cropper.getContainerData().height - scaledHeight) / 2,
      width: scaledWidth,
      height: scaledHeight
    });

    this.cropper.setCropBoxData({
      width: cropWidth,
      height: cropHeight,
      left: cropLeft,
      top: cropTop
    });
  }

  updatePreview() {
    const canvas = this.cropper.getCroppedCanvas({
      width: 250,
      height: 360,
    });

    const croppedImageDataUrl = canvas.toDataURL();

    if (this.outputRoundedTarget) {
      this.outputRoundedTarget.src = croppedImageDataUrl;
    }

    if (this.outputDefaultTarget) {
      this.outputDefaultTarget.src = croppedImageDataUrl;

      setTimeout(() => {
        this.outputDefaultTarget.classList.remove("image-preview-hidden");
      }, 100);
    }
  }

  updateFileInput() {
    const canvas = this.cropper.getCroppedCanvas({
      width: 1000,
      height: 1440,
    });

    canvas.toBlob((blob) => {
      let file = new File([blob], "cropped_image.jpg", { type: "image/jpeg" });
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      this.fileTarget.files = dataTransfer.files;
    }, 'image/jpeg');
  }
}
