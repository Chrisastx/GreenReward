;; GreenReward - Decentralized Carbon Credit Marketplace
;; A platform for issuing, trading, and retiring carbon credits

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_CREDIT_NOT_FOUND (err u103))
(define-constant ERR_CREDIT_ALREADY_RETIRED (err u104))
(define-constant ERR_INVALID_PRICE (err u105))
(define-constant ERR_SELF_TRADE (err u106))
(define-constant ERR_INVALID_STRING (err u107))
(define-constant ERR_EMPTY_BATCH (err u108))
(define-constant ERR_BATCH_TOO_LARGE (err u109))
(define-constant MAX_BATCH_SIZE u50) ;; Maximum batch size for operations

;; Data Variables
(define-data-var next-credit-id uint u1)
(define-data-var platform-fee uint u250) ;; 2.5% fee (250 basis points)

;; Data Maps
(define-map carbon-credits
  uint
  {
    issuer: principal,
    owner: principal,
    amount: uint,
    price-per-credit: uint,
    project-type: (string-ascii 50),
    verification-standard: (string-ascii 30),
    issue-date: uint,
    retired: bool,
    for-sale: bool
  }
)

(define-map user-balances
  principal
  {
    total-credits: uint,
    total-retired: uint
  }
)

(define-map marketplace-listings
  uint
  {
    seller: principal,
    price-per-credit: uint,
    available-amount: uint,
    listing-date: uint
  }
)

;; Private Functions
(define-private (is-valid-amount (amount uint))
  (> amount u0)
)

(define-private (is-valid-price (price uint))
  (> price u0)
)

(define-private (is-valid-string (input (string-ascii 50)))
  (and (> (len input) u0) (<= (len input) u50))
)

(define-private (is-valid-verification-standard (input (string-ascii 30)))
  (and (> (len input) u0) (<= (len input) u30))
)

(define-private (update-user-balance (user principal) (credits uint) (retired uint))
  (let ((current-balance (default-to {total-credits: u0, total-retired: u0} (map-get? user-balances user))))
    (map-set user-balances user {
      total-credits: (+ (get total-credits current-balance) credits),
      total-retired: (+ (get total-retired current-balance) retired)
    })
  )
)

;; Batch operation helper functions
(define-private (validate-batch-size (batch-size uint))
  (and (> batch-size u0) (<= batch-size MAX_BATCH_SIZE))
)

(define-private (process-single-credit-issuance 
  (credit-data {amount: uint, price: uint, project-type: (string-ascii 50), verification-standard: (string-ascii 30)})
  (acc {success: bool, total-amount: uint, credit-ids: (list 50 uint)}))
  (if (get success acc)
    (let (
      (amount (get amount credit-data))
      (price (get price credit-data))
      (project-type (get project-type credit-data))
      (verification-standard (get verification-standard credit-data))
      (credit-id (var-get next-credit-id))
    )
      (if (and 
            (is-valid-amount amount)
            (is-valid-price price)
            (is-valid-string project-type)
            (is-valid-verification-standard verification-standard))
        (begin
          (map-set carbon-credits credit-id {
            issuer: tx-sender,
            owner: tx-sender,
            amount: amount,
            price-per-credit: price,
            project-type: project-type,
            verification-standard: verification-standard,
            issue-date: stacks-block-height,
            retired: false,
            for-sale: false
          })
          (var-set next-credit-id (+ credit-id u1))
          {
            success: true,
            total-amount: (+ (get total-amount acc) amount),
            credit-ids: (unwrap-panic (as-max-len? (append (get credit-ids acc) credit-id) u50))
          }
        )
        {success: false, total-amount: (get total-amount acc), credit-ids: (get credit-ids acc)}
      )
    )
    acc
  )
)

(define-private (process-single-credit-retirement 
  (credit-id uint)
  (acc {success: bool, total-retired: uint, retired-ids: (list 50 uint)}))
  (if (get success acc)
    (match (map-get? carbon-credits credit-id)
      credit 
        (if (and 
              (is-eq (get owner credit) tx-sender)
              (not (get retired credit)))
          (begin
            (map-set carbon-credits credit-id (merge credit {
              retired: true,
              for-sale: false
            }))
            (map-delete marketplace-listings credit-id)
            {
              success: true,
              total-retired: (+ (get total-retired acc) (get amount credit)),
              retired-ids: (unwrap-panic (as-max-len? (append (get retired-ids acc) credit-id) u50))
            }
          )
          {success: false, total-retired: (get total-retired acc), retired-ids: (get retired-ids acc)}
        )
      {success: false, total-retired: (get total-retired acc), retired-ids: (get retired-ids acc)}
    )
    acc
  )
)

;; Public Functions

;; Issue new carbon credits
(define-public (issue-credits (amount uint) (price uint) (project-type (string-ascii 50)) (verification-standard (string-ascii 30)))
  (let ((credit-id (var-get next-credit-id)))
    (asserts! (is-valid-amount amount) ERR_INVALID_AMOUNT)
    (asserts! (is-valid-price price) ERR_INVALID_PRICE)
    (asserts! (is-valid-string project-type) ERR_INVALID_STRING)
    (asserts! (is-valid-verification-standard verification-standard) ERR_INVALID_STRING)
    
    (map-set carbon-credits credit-id {
      issuer: tx-sender,
      owner: tx-sender,
      amount: amount,
      price-per-credit: price,
      project-type: project-type,
      verification-standard: verification-standard,
      issue-date: stacks-block-height,
      retired: false,
      for-sale: false
    })
    
    (update-user-balance tx-sender amount u0)
    (var-set next-credit-id (+ credit-id u1))
    (ok credit-id)
  )
)

;; Batch issue carbon credits
(define-public (batch-issue-credits 
  (credits-data (list 50 {amount: uint, price: uint, project-type: (string-ascii 50), verification-standard: (string-ascii 30)})))
  (let (
    (batch-size (len credits-data))
    (result (fold process-single-credit-issuance credits-data {success: true, total-amount: u0, credit-ids: (list)}))
  )
    (asserts! (validate-batch-size batch-size) ERR_EMPTY_BATCH)
    (asserts! (get success result) ERR_INVALID_AMOUNT)
    
    (update-user-balance tx-sender (get total-amount result) u0)
    (ok {
      total-issued: batch-size,
      total-amount: (get total-amount result),
      credit-ids: (get credit-ids result)
    })
  )
)

;; List credits for sale
(define-public (list-for-sale (credit-id uint) (price-per-credit uint))
  (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    (asserts! (is-valid-price price-per-credit) ERR_INVALID_PRICE)
    
    (map-set carbon-credits credit-id (merge credit {
      for-sale: true,
      price-per-credit: price-per-credit
    }))
    
    (map-set marketplace-listings credit-id {
      seller: tx-sender,
      price-per-credit: price-per-credit,
      available-amount: (get amount credit),
      listing-date: stacks-block-height
    })
    
    (ok true)
  )
)

;; Purchase carbon credits
(define-public (purchase-credits (credit-id uint) (amount uint))
  (let (
    (credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND))
    (listing (unwrap! (map-get? marketplace-listings credit-id) ERR_CREDIT_NOT_FOUND))
    (total-cost (* amount (get price-per-credit credit)))
    (fee (/ (* total-cost (var-get platform-fee)) u10000))
    (seller-payment (- total-cost fee))
  )
    (asserts! (get for-sale credit) ERR_CREDIT_NOT_FOUND)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    (asserts! (not (is-eq tx-sender (get owner credit))) ERR_SELF_TRADE)
    (asserts! (is-valid-amount amount) ERR_INVALID_AMOUNT)
    (asserts! (<= amount (get available-amount listing)) ERR_INSUFFICIENT_BALANCE)
    
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? seller-payment tx-sender (get seller listing)))
    
    ;; Transfer platform fee to contract owner
    (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
    
    ;; Update credit ownership
    (map-set carbon-credits credit-id (merge credit {
      owner: tx-sender,
      amount: amount,
      for-sale: false
    }))
    
    ;; Update balances
    (update-user-balance tx-sender amount u0)
    (update-user-balance (get seller listing) (- u0 amount) u0)
    
    ;; Remove from marketplace
    (map-delete marketplace-listings credit-id)
    
    (ok true)
  )
)

;; Retire carbon credits
(define-public (retire-credits (credit-id uint))
  (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get retired credit)) ERR_CREDIT_ALREADY_RETIRED)
    
    (map-set carbon-credits credit-id (merge credit {
      retired: true,
      for-sale: false
    }))
    
    (update-user-balance tx-sender (- u0 (get amount credit)) (get amount credit))
    (map-delete marketplace-listings credit-id)
    (ok true)
  )
)

;; Batch retire carbon credits
(define-public (batch-retire-credits (credit-ids (list 50 uint)))
  (let (
    (batch-size (len credit-ids))
    (result (fold process-single-credit-retirement credit-ids {success: true, total-retired: u0, retired-ids: (list)}))
  )
    (asserts! (validate-batch-size batch-size) ERR_EMPTY_BATCH)
    (asserts! (get success result) ERR_UNAUTHORIZED)
    
    (update-user-balance tx-sender (- u0 (get total-retired result)) (get total-retired result))
    (ok {
      total-retired: batch-size,
      total-amount: (get total-retired result),
      retired-ids: (get retired-ids result)
    })
  )
)

;; Remove from sale
(define-public (remove-from-sale (credit-id uint))
  (let ((credit (unwrap! (map-get? carbon-credits credit-id) ERR_CREDIT_NOT_FOUND)))
    (asserts! (is-eq (get owner credit) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (get for-sale credit) ERR_CREDIT_NOT_FOUND)
    
    (map-set carbon-credits credit-id (merge credit {for-sale: false}))
    (map-delete marketplace-listings credit-id)
    (ok true)
  )
)

;; Read-only functions

;; Get credit details
(define-read-only (get-credit-details (credit-id uint))
  (map-get? carbon-credits credit-id)
)

;; Get user balance
(define-read-only (get-user-balance (user principal))
  (default-to {total-credits: u0, total-retired: u0} (map-get? user-balances user))
)

;; Get marketplace listing
(define-read-only (get-marketplace-listing (credit-id uint))
  (map-get? marketplace-listings credit-id)
)

;; Get platform fee
(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

;; Get next credit ID
(define-read-only (get-next-credit-id)
  (var-get next-credit-id)
)

;; Get maximum batch size
(define-read-only (get-max-batch-size)
  MAX_BATCH_SIZE
)

;; Check if credit is available for purchase
(define-read-only (is-credit-available (credit-id uint))
  (match (map-get? carbon-credits credit-id)
    credit (and (get for-sale credit) (not (get retired credit)))
    false
  )
)

;; Admin functions (owner only)

;; Update platform fee
(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-fee u1000) ERR_INVALID_AMOUNT) ;; Max 10% fee
    (var-set platform-fee new-fee)
    (ok true)
  )
)