import Foundation
import StoreKit

/// Manages StoreKit 2 in-app purchases for the premium upgrade.
@MainActor @Observable
final class StoreManager {

    static let shared = StoreManager()

    // MARK: - State

    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var premiumProduct: Product?
    private(set) var purchaseError: String?

    var isPremium: Bool {
        purchasedProductIDs.contains(Self.premiumProductID)
    }

    // MARK: - Constants

    static let premiumProductID = "com.cribbage.premium"

    // MARK: - Init

    private init() {
        listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.premiumProductID])
            premiumProduct = products.first
        } catch {
            purchaseError = "Failed to load products."
        }
    }

    // MARK: - Purchase

    @discardableResult
    func purchase() async -> Bool {
        guard let product = premiumProduct else {
            purchaseError = "Product not available."
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                purchaseError = nil
                return true
            case .userCancelled:
                return false
            case .pending:
                purchaseError = "Purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = "Purchase failed. Please try again."
            return false
        }
    }

    // MARK: - Restore

    func restore() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            if !isPremium {
                purchaseError = "No purchases to restore."
            } else {
                purchaseError = nil
            }
        } catch {
            purchaseError = "Restore failed. Please try again."
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? result.payloadValue {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }

    // MARK: - Entitlements

    func updatePurchasedProducts() async {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                ids.insert(transaction.productID)
            }
        }
        purchasedProductIDs = ids
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    private enum StoreError: Error {
        case verificationFailed
    }
}
