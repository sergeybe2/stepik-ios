import Foundation
import PromiseKit

protocol UserCoursesNetworkServiceProtocol: AnyObject {
    func fetch(page: Int) -> Promise<([UserCourse], Meta)>
    func fetch(courseID: Course.IdType) -> Promise<UserCourse?>

    func update(userCourse: UserCourse) -> Promise<UserCourse>
}

extension UserCoursesNetworkServiceProtocol {
    func fetch() -> Promise<([UserCourse], Meta)> {
        self.fetch(page: 1)
    }
}

final class UserCoursesNetworkService: UserCoursesNetworkServiceProtocol {
    private let userCoursesAPI: UserCoursesAPI

    init(userCoursesAPI: UserCoursesAPI) {
        self.userCoursesAPI = userCoursesAPI
    }

    func fetch(page: Int) -> Promise<([UserCourse], Meta)> {
        Promise { seal in
            self.userCoursesAPI.retrieve(page: page).done { userCourses, meta in
                seal.fulfill((userCourses, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(courseID: Course.IdType) -> Promise<UserCourse?> {
        Promise { seal in
            self.userCoursesAPI.retrieve(courseID: courseID).done { userCourses, _ in
                seal.fulfill(userCourses.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func update(userCourse: UserCourse) -> Promise<UserCourse> {
        Promise { seal in
            self.userCoursesAPI.update(userCourse).done { userCourse in
                seal.fulfill(userCourse)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case updateFailed
    }
}
