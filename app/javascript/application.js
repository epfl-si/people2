// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

// Disabling file attachment functionality
// Taken from: https://github.com/basecamp/trix/issues/604#issuecomment-1114265604
addEventListener('trix-initialize', function(e) {
  $('.disable-trix-file-attachment').each(function(e) {
    // Remove file-attach icon
    $(this).find('trix-toolbar .trix-button-group--file-tools').remove();
    // Disables functionality to drag-and-drop files onto the trix-editor
    $(this).find('trix-editor').on('trix-file-accept', function(e) {
      e.preventDefault();
    });
  });
});
