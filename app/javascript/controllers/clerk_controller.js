
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["signedIn", "signedOut", "userName"]

  async connect() {
    this.handleAuthChange = this.handleAuthChange.bind(this)

    try {
      await this.waitForWindowLoad()

      if (!window.Clerk) {
        throw new Error("ClerkJS was not loaded.")
      }

      await window.Clerk.load({
        ui: {
          ClerkUI: window.__internal_ClerkUICtor
        }
      })

      this.clerk = window.Clerk

      this.unsubscribe = this.clerk.addListener(this.handleAuthChange)

      this.mountSignIn()
    } catch (error) {
      console.error("Unable to initialize Clerk:", error)
    }
  }

  disconnect() {
    this.unsubscribe?.()

    if (this.signInContainer && this.clerk) {
      this.clerk.unmountSignIn(this.signInContainer)
      this.signInContainer = null
    }
  }

  mountSignIn() {
    this.signInContainer = document.getElementById("clerk-sign-in-container")

    if (!this.signInContainer || this.clerk.isSignedIn) {
      return
    }

    // Remove the loading placeholder before mounting Clerk UI.
    this.signInContainer.replaceChildren()

    this.clerk.mountSignIn(this.signInContainer, {
      fallbackRedirectUrl: "/",
      signUpFallbackRedirectUrl: "/"
    })
  }

  async signIn() {
    await this.clerk?.openSignIn()
  }

  async signOut() {
    await this.clerk?.signOut({
      redirectUrl: "/"
    })
  }

  handleAuthChange({ user }) {
    const authenticated = Boolean(user)

    if (this.hasSignedInTarget) {
      this.signedInTarget.classList.toggle("hidden", !authenticated)
    }

    if (this.hasSignedOutTarget) {
      this.signedOutTarget.classList.toggle("hidden", authenticated)
    }

    if (this.hasUserNameTarget) {
      this.userNameTarget.textContent = authenticated
        ? user.fullName ||
          user.primaryEmailAddress?.emailAddress ||
          "Account"
        : ""
    }

    if (authenticated && window.location.pathname === "/sign-in") {
      window.location.assign("/")
    }
  }

  waitForWindowLoad() {
    if (document.readyState === "complete") {
      return Promise.resolve()
    }

    return new Promise((resolve) => {
      window.addEventListener("load", resolve, { once: true })
    })
  }
}
