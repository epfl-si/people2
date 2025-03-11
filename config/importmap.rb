# frozen_string_literal: true

# Pin packages (pin=install and declare here) packages by running
# ./bin/importmap package_name
# Example:
# ./bin/importmap pin @stimulus-components/popover

# !! REMEMBER to also import and register controllers from @stimulus-components
# into controllers/index.js. Example:
# import Popover from '@stimulus-components/popover'
# application.register('popover', Popover)

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@stimulus-components/auto-submit", to: "@stimulus-components--auto-submit.js" # @6.0.0
pin "@stimulus-components/popover", to: "@stimulus-components--popover.js" # @7.0.0
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.9
pin "sortablejs" # @1.15.2
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "cropperjs" # @1.6.2
