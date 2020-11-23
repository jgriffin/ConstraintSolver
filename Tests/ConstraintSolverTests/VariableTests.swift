
@testable import ConstraintSolver
import XCTest

class VariableTests: XCTestCase {
    func testIdentity() {
        let var1 = Variable<Int>()
        let var2 = var1
        let var3 = Variable<Int>()
        XCTAssertTrue(var1 == var2)
        XCTAssertFalse(var1 == var3)
        XCTAssertFalse(var2 == var3)
    }
}
