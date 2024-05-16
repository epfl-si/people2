// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// animate turbo frame replacements (https://edforshaw.co.uk/hotwire-turbo-stream-animations)
document.addEventListener("turbo:before-stream-render", function(event) {
  // Add "turbo-replace-enter" class to an element we are about to add to the page
  if (event.target.firstElementChild instanceof HTMLTemplateElement) {
    event.target.templateElement.content.firstElementChild.classList.add("turbo-replace-enter")
  }

  // Add "turbo-replace-enter" class to the element we are about to remove from the page
  var elementToRemove = document.getElementById(event.target.target)
  if (elementToRemove) {
    event.preventDefault()
    elementToRemove.classList.add("turbo-replace-exit")
      // Wait for its animation to end before removing the element
    elementToRemove.addEventListener("animationend", function() {
      event.target.performAction()
    })
  }
})