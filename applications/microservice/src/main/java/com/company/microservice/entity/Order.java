package com.company.microservice.entity;

public record Order(int id, int customerId, String product, int quantity) {
}