(ns build
  (:require [clojure.tools.build.api :as b]))

(def lib 'stylesheets)
(def version (format "%s" (b/git-count-revs nil)))
(def class-dir "target/classes")
(def uber-file "target/stylesheets.jar")

;; delay to defer side effects (artifact downloads)
(def basis (delay (b/create-basis {:project "deps.edn"})))

(defn clean [_]
  (b/delete {:path "target"}))

(defn uberjar [_]
  (clean nil)
  (b/copy-dir {:src-dirs ["src"]
               :target-dir class-dir})
  (b/compile-clj {:basis @basis
                  :ns-compile '[stylesheets.core]
                  :class-dir class-dir})
  (b/uber {:class-dir class-dir
           :uber-file uber-file
           :basis @basis
           :main 'stylesheets.core}))
