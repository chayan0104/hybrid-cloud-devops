import { bootstrapApplication } from "@angular/platform-browser";
import { Component } from "@angular/core";

const environment = {
  monolithPath: "/monolith",
  microservicePath: "/microservice",
};

@Component({
  selector: "app-root",
  standalone: true,
  template: `
    <main class="page">
      <section class="hero">
        <h1>Chayan App</h1>
        <p>Frontend -> Monolith and Microservice with real MySQL-backed orders.</p>
        <div class="quick-links">
          <a target="_blank" rel="noreferrer" href="/monolith/swagger">Monolith Swagger</a>
          <a target="_blank" rel="noreferrer" href="/microservice/swagger-ui.html">Microservice Swagger</a>
        </div>
      </section>

      <section class="panel">
        <label>
          Customer ID
          <input type="number" [value]="customerId" (input)="onIdChange($event)" min="1" />
        </label>

        <div class="actions">
          <button type="button" (click)="loadCustomer()">Get Customer</button>
          <button type="button" (click)="loadOrders()">Get Orders</button>
          <button type="button" (click)="loadSummary()">Get Customer Summary</button>
        </div>
      </section>

      <pre>{{ result }}</pre>
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

      .hero {
        margin-bottom: 24px;
      }

      .quick-links {
        display: flex;
        gap: 12px;
        margin-top: 12px;
        flex-wrap: wrap;
      }

      .quick-links a {
        color: #67e8f9;
        text-decoration: none;
        border-bottom: 1px solid #164e63;
      }

      h1 {
        margin: 0;
        font-size: 2.4rem;
        letter-spacing: -0.03em;
      }

      p {
        color: #cbd5e1;
      }

      .panel {
        border: 1px solid #334155;
        background: linear-gradient(180deg, #111827, #0b1220);
        padding: 16px;
      }

      label {
        display: grid;
        gap: 8px;
        margin-top: 20px;
        max-width: 220px;
      }

      input {
        padding: 8px;
      }

      .actions {
        display: flex;
        gap: 8px;
        margin-top: 16px;
        flex-wrap: wrap;
      }

      button {
        padding: 8px 12px;
        border: 1px solid #475569;
        background: #1e293b;
        color: #e2e8f0;
        cursor: pointer;
      }

      button:hover {
        background: #334155;
      }

      pre {
        margin-top: 20px;
        background: #020617;
        border: 1px solid #334155;
        padding: 16px;
        white-space: pre-wrap;
        min-height: 220px;
      }
    `
  ]
})
class AppComponent {
  customerId = 1;
  result = "Click a button to fetch data.";

  onIdChange(event: Event) {
    const value = Number((event.target as HTMLInputElement).value);
    this.customerId = Number.isFinite(value) && value > 0 ? value : 1;
  }

  async loadCustomer() {
    this.result = await this.fetchJson(`${environment.monolithPath}/api/customer/${this.customerId}`);
  }

  async loadOrders() {
    this.result = await this.fetchJson(`${environment.microservicePath}/api/orders/${this.customerId}`);
  }

  async loadSummary() {
    this.result = await this.fetchJson(`${environment.monolithPath}/api/customer-summary/${this.customerId}`);
  }

  private async fetchJson(url: string): Promise<string> {
    try {
      const response = await fetch(url);
      const text = await response.text();
      return JSON.stringify(JSON.parse(text), null, 2);
    } catch {
      return "Request failed";
    }
  }
}

bootstrapApplication(AppComponent).catch((err) => console.error(err));