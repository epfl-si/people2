// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

// Animate turbo frame replacements (https://edforshaw.co.uk/hotwire-turbo-stream-animations)
// TODO: I think this induces some strange behaviour to the turbo-replacement
// thing preventing edit of a newly created record.
document.addEventListener("turbo:before-stream-render", function(event) {
  // Add "turbo-replace-enter" class to an element we are about to add to the page
  if (event.target.firstElementChild instanceof HTMLTemplateElement) {
    elementToAdd = event.target.templateElement.content.firstElementChild
    elementToAdd.classList.add("turbo-replace-enter")
  } else {
    elementToAdd = false
  }

  // Add "turbo-replace-enter" class to the element we are about to remove from the page
  var elementToRemove = document.getElementById(event.target.target)
  if (elementToRemove) {
    event.preventDefault()
    elementToRemove.classList.add("turbo-replace-exit")
      // Wait for its animation to end before removing the element
    elementToRemove.addEventListener("animationend", function() {
      event.target.performAction()
      if (elementToAdd) {
        elementToAdd.classList.remove("turbo-replace-enter")
      }
    })
  }
})
