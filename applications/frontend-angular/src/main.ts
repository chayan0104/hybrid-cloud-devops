import { bootstrapApplication } from "@angular/platform-browser";
import { Component } from "@angular/core";

const environment = {
  monolithUrl: "http://localhost:9092",
  microserviceUrl: "http://localhost:9093",
};

@Component({
  selector: "app-root",
  standalone: true,
  template: `
    <main class="page">
      <h1>Chayan App UI</h1>
      <p>Frontend calls Monolith and Microservice directly.</p>

      <label>
        Customer ID
        <input type="number" [value]="customerId" (input)="onIdChange($event)" min="1" />
      </label>

      <div class="actions">
        <button type="button" (click)="loadCustomer()">Get Customer</button>
        <button type="button" (click)="loadOrders()">Get Orders</button>
        <button type="button" (click)="loadSummary()">Get Customer Summary</button>
      </div>

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

      h1 {
        margin: 0;
        font-size: 2rem;
      }

      p {
        color: #cbd5e1;
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

      pre {
        margin-top: 20px;
        background: #020617;
        border: 1px solid #334155;
        padding: 16px;
        white-space: pre-wrap;
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
    this.result = await this.fetchJson(`${environment.monolithUrl}/main-app/api/customer/${this.customerId}`);
  }

  async loadOrders() {
    this.result = await this.fetchJson(`${environment.microserviceUrl}/api/orders/${this.customerId}`);
  }

  async loadSummary() {
    this.result = await this.fetchJson(`${environment.monolithUrl}/main-app/api/customer-summary/${this.customerId}`);
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