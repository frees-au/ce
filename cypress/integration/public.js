describe("Public access tests", () => {
  beforeEach(() => {
    cy.fixture("public-urls.json").as("urls");
  });
  it("Do it", function () {
    const urls = this.urls;
    for (const url in urls) {
      cy.visit(urls[url]);
    }

    cy.visit("/ce")
    cy.contains("Free Sauce is a purpose driven agency")
  });

});
