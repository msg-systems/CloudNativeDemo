/// <reference types="Cypress" />

describe('Calculator integration tests', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('should have an "home" screen', () => {
    cy.contains('h1', 'Home');
  });

  function shouldContainHistoryEntry(leftOperand, operation, rightOperand, expectedSum) {
    cy.contains('[data-testid=calculator-history-table] tbody tr:first-child', expectedSum.toString()).within(() => {
      cy.get('td').eq(0).should('have.text', leftOperand.toString());
      cy.get('td').eq(1).should('have.text', operation);
      cy.get('td').eq(2).should('have.text', rightOperand.toString());
      cy.get('td').eq(3).should('have.text', expectedSum.toString());
    });
  }

  describe('Classic Calculator', () => {
    beforeEach(() => {
      cy.contains('.p-menuitem-text', 'Classic Calculator').click();
    });

    function clickButton(text) {
      cy.contains('button', text).click();
    }
    function clickButtons(...texts) {
      texts.forEach((text) => clickButton(text));
    }

    it('should calculate the sum of two numbers and display the result in the history', () => {
      cy.get('[data-testid=clearHistory]').click();

      clickButtons('1', '+', '2', '=');

      cy.get('[data-testid=result]').should('have.value', '1 + 2 = 3');
      shouldContainHistoryEntry(1, 'ADD', 2, 3);
    });
  });
});
