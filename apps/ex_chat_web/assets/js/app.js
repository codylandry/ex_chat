
// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import Alpine from 'alpinejs'
import EasyMDE from 'easymde'

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

window.Alpine = Alpine
Alpine.start()

let Hooks = {}
Hooks.PostContainerScrollHandler = {
    mounted() {
        this.el.scrollTop = this.el.scrollHeight

        this.handleEvent("post-added", () => {
            this.el.scrollTop = this.el.scrollHeight
        })
    }
}

Hooks.PostEditor = {
    mounted() {
        const submitBtn = document.getElementById('post-form-submit')
        this.el.addEventListener("keydown", event => {
            if (event.key == "Enter" && event.metaKey) {
                submitBtn.click()
            }
        })

        const form = document.getElementById('post-form')
        form.addEventListener("submit", event => {
            setTimeout(() => {
                this.el.value = ""
            })
        })
    }
}

let liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: { _csrf_token: csrfToken },
    dom: {
        onBeforeElUpdated(from, to) {
            if (from._x_dataStack) {
                window.Alpine.clone(from, to)
            }
        }
    }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

