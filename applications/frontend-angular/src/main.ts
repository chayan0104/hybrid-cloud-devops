import { bootstrapApplication } from "@angular/platform-browser";
import { Component } from "@angular/core";

@Component({
  selector: "app-root",
  standalone: true,
  template: `
    <main class="page">
      <h1>Enterprise Frontend (Angular)</h1>
      <p>Dedicated UI application for the hybrid cloud platform.</p>
      <ul>
        <li>Runtime: Angular 18 standalone app</li>
        <li>Target: Dockerized frontend service</li>
        <li>Path: applications/frontend-angular</li>
      </ul>
    </main>
  `,
  styles: [
    `
      .page {
        min-height: 100vh;
        padding: 48px 24px;
        max-width: 960px;
        margin: 0 auto;
      }

      h1 {
        margin: 0;
        font-size: 2rem;
      }

      p {
        color: #cbd5e1;
      }

      ul {
        color: #94a3b8;
        padding-left: 18px;
      }
    `
  ]
})
class AppComponent {}

bootstrapApplication(AppComponent).catch((err) => console.error(err));