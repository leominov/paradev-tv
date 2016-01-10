angular.module('myApp.controllers', [])

    .controller('AppController', function ($scope, $http, $cookies) {
        var now = new Date();
        var exp = new Date(now.getFullYear(), now.getMonth() + 1, now.getDate());

        $scope.allow_new_users = false;
        $scope.check_error = false;

        $scope.stepper = false;
        $scope.user_form = false;
        $scope.type_run = 'signin';

        $scope.playlist = false;

        $scope.preloader = true;

        $scope.is_auth = false;
        $scope.user = {};

        auth();

        $scope.Run = function(tr) {
            $scope.reg_login = "";
            $scope.reg_password = "";

            $scope.playlist = false;
            $scope.stepper = true;
            $scope.user_form = true;
            $scope.type_run = tr;
        };

        $scope.Done = function(tr) {
            if ($scope.reg.$invalid) {
                return false;
            }

            $http.get('/' + tr + '?login=' + $scope.reg_login + '&password=' + $scope.reg_password)
                .success(function (result) {
                    if (result.result) {
                        $scope.user_form = false;
                        $scope.playlist = true;
                        $cookies.put('auth', $scope.reg_login + '~' + result.token, {expires: exp});
                        auth();
                    } else {
                        $scope.check_error = true;
                        $scope.error_code = false;
                    }
                })
                .error(function (result) {
                    $scope.check_error = true;
                    $scope.error_code = result.error_code;
                });
        };

        $scope.Signout = function() {
            $scope.stepper = false;
            $scope.user_form = false;

            $http.defaults.headers.common['X-Authorization'] = "";
            $cookies.remove('auth');
            auth();
        };

        $scope.Undone = function() {
            $scope.stepper = false;
            $scope.user_form = false;
            $scope.check_error = false;
        };

        function checkAllowNewUsers() {
            $http.get('/check')
                .success(function (result) {
                    $scope.allow_new_users = result.result;
                });
        }

        function auth() {
            if ($cookies.get('auth') !== undefined) {
                $http.defaults.headers.common['X-Authorization'] = $cookies.get('auth');
            }

            $http.get('/auth')
                .success(function (result) {
                    $scope.user = result.user;
                    $scope.is_auth = true;

                    $scope.stepper = true;
                    $scope.playlist = true;

                    $scope.preloader = false;
                })
                .error(function (result) {
                    checkAllowNewUsers();

                    $scope.preloader = false;
                });
        }
    });
